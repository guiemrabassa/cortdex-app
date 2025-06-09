use core::fmt;
use std::{
    fs::{read, read_to_string},
    sync::Arc,
};

use anyhow::Context;
use candle_transformers::models::bert::{BertModel, Config, HiddenAct, DTYPE};

use candle_core::Tensor;
use candle_nn::VarBuilder;

use cortdex_types::embedding::{EmbeddingDiff, EmbeddingOfNote};
use dashmap::DashMap;
use flutter_rust_bridge::frb;
use log::{debug, error};
use tokenizers::Tokenizer;

use crate::{
    api::manager::ModelManagerConfig,
    embedder::Embedder,
    error::{EmbeddingError, ModelStatus},
};

#[frb(opaque)]
pub struct ModelManager {
    models: DashMap<String, EmbeddingModel>,
    config: ModelManagerConfig,
}

impl ModelManager {

    pub fn config(&self) -> &ModelManagerConfig {
        &self.config
    }

    #[frb(sync)]
    pub fn new(config: ModelManagerConfig) -> Self {
        // TODO: Mk new models dir
        // TODO: Auto search everything?

        Self {
            models: DashMap::new(),
            config,
        }
    }

    pub async fn setup(&mut self) -> anyhow::Result<()> {
        self.load_model(self.config.selected.clone()).await
    }

    pub fn change_config(&mut self, new_config: ModelManagerConfig) {
        self.config = new_config;
    }

    pub fn check_model_directory(&self, model_id: &String) -> ModelStatus {
        let path_id = model_id.replace("/", "---");
        let dir = format!("{}/{}", self.config.model_dir, path_id);
        debug!("Checking: {dir}");
        ModelStatus::new(&dir)
    }

    pub fn get_model(&self) -> anyhow::Result<dashmap::mapref::one::Ref<'_, String, EmbeddingModel>> {
        self.models
            .get(&self.config.selected)
            .context(format!("Failed to load model {}", self.config.selected))
    }

    pub async fn load_model(&self, model_id: String) -> anyhow::Result<()> {
        let path_id = model_id.replace("/", "---");
        let dir = format!("{}/{}", self.config.model_dir, path_id);

        // TODO: Make model status into err
        let status = ModelStatus::new(&dir);

        if !status.is_ok() {
            return Err(anyhow::Error::msg(format!("For dir {dir} the status is: {status:?}")));
        }

        let mut config: Config =
            serde_json::from_str(&read_to_string(format!("{dir}/config.json"))?)?;
        let tokenizer: Tokenizer =
            serde_json::from_str(&read_to_string(format!("{dir}/tokenizer.json"))?)?;

        let model = read(format!("{dir}/model.safetensors"))?;
        let approximate_gelu = false;

        // TODO: Fix

        let cpu = true;

        let device = candle_examples::device(cpu)?;

        let vb = VarBuilder::from_buffered_safetensors(model, DTYPE, &device)?;

        if approximate_gelu {
            config.hidden_act = HiddenAct::GeluApproximate;
        }

        let model = BertModel::load(vb, &config)?;

        self.models.insert(model_id.clone(), EmbeddingModel {
            name: model_id,
            model: Arc::new(model),
            config,
            tokenizer,
        });

        Ok(())
    }
}

#[derive(Clone)]
pub struct EmbeddingModel {
    name: String,
    model: Arc<BertModel>,
    config: Config,
    tokenizer: Tokenizer,
}

impl fmt::Display for EmbeddingModel {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.name)
    }
}

impl fmt::Debug for EmbeddingModel {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("NewEmbedModel")
            .field("name", &self.name)
            .field("config", &self.config)
            .field("tokenizer", &self.tokenizer)
            .finish()
    }
}

impl Embedder for EmbeddingModel {
    // TODO: Maybe change to accept anything that can be an embeddable?
    fn get_embeddings(&self, text: String) -> Result<Vec<f32>, EmbeddingError> {
        let device = &self.model.device;

        // TODO: Look into this
        let mut tokenizer = self.tokenizer.clone();

        let tokenizer = tokenizer.with_padding(None).with_truncation(None)?;

        let tokens = tokenizer.encode(text, true)?.get_ids().to_vec();
        let token_ids = Tensor::new(&tokens[..], device)?.unsqueeze(0)?;
        let token_type_ids = token_ids.zeros_like()?;

        let ys = self.model.forward(&token_ids, &token_type_ids, None)?;
        // ys.sum(0)?.reshape(&[96, 4])?.to_vec1().map_err(E::msg)

        ys.sum([0, 1])?.to_vec1().map_err(Into::into)
    }

    fn calc_embeddings(&self, diffs: Vec<EmbeddingDiff>) -> Vec<EmbeddingOfNote> {
        diffs
            .into_iter()
            .filter_map(|diff| {
                match self.get_embeddings(format!("{}\n{}", diff.title, diff.content)) {
                    Ok(embedding) => Some(EmbeddingOfNote {
                        id: diff.id,
                        vectors: embedding,
                    }),
                    Err(err) => {
                        error!(
                            "Failed to calculate embeddings for {} due to: {}",
                            diff.id, err
                        );
                        None
                    }
                }
            })
            .collect()
    }
}
