use std::path::PathBuf;

// use candle_hf_hub::api::sync::ApiBuilder;

use candle_hf_hub::api::tokio::ApiBuilder;
use flutter_rust_bridge::frb;
use log::debug;
use serde::{Deserialize, Serialize};

use crate::manager::ModelManager;


#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct ModelManagerConfig {
    pub selected: String,
    pub dir: String,
    pub model_dir: String,
}

impl ModelManagerConfig {

    #[frb(sync)]
    pub fn new_basic(dir: String) -> Self {
        let model_dir = format!("{dir}/models");
        let selected = "sentence-transformers/all-MiniLM-L6-v2".to_string();
        Self { selected, dir, model_dir }
    }

}

impl ModelManager {

    // TODO: Return all settings to store in the SharedPreferences
    pub fn serialized_settings(&self) -> anyhow::Result<String> {
        serde_json::to_string(&self.config()).map_err(Into::into)
    }

    pub async fn download_new_model(&self, model_id: String) -> anyhow::Result<()> {
        let cache: PathBuf = format!("{}/cache", self.config().dir).into();
        // TODO: Check if it's better to use tokio's apibuilder

        
        
        let api = ApiBuilder::new().with_cache_dir(cache.clone()).build()?;
        let repo = api.model(model_id.clone());

        repo.info().await?
            .siblings
            .iter()
            .for_each(|sibling| debug!("{}", sibling.rfilename));

        // TODO: Change this to allow for loading without triggering a download, and also the ability to stop it?
        let mut model_path = repo.download("model.safetensors").await?;
        let mut config_path = repo.download("config.json").await?;
        let mut tokenizer_path = repo.download("tokenizer.json").await?;

        if model_path.is_symlink() {
            model_path = std::fs::canonicalize(model_path)?;
        }

        if config_path.is_symlink() {
            config_path = std::fs::canonicalize(config_path)?;
        }

        if tokenizer_path.is_symlink() {
            tokenizer_path = std::fs::canonicalize(tokenizer_path)?;
        }

        let model_id = model_id.replace("/", "---");

        let new_dir = format!("{}/{model_id}", self.config().model_dir);

        debug!("New dir: {new_dir}");

        std::fs::create_dir_all(new_dir.clone())?;

        std::fs::rename(model_path, format!("{new_dir}/model.safetensors"))?;
        std::fs::rename(config_path, format!("{new_dir}/config.json"))?;
        std::fs::rename(tokenizer_path, format!("{new_dir}/tokenizer.json"))?;

        // TODO: Maybe in the future just remove the model from cache, instead of all cache?
        std::fs::remove_dir_all(cache)?;

        Ok(())
    }

    pub async fn remove_model(&self, model_id: String) -> anyhow::Result<()> {
        let model_id = model_id.replace("/", "---");

        std::fs::remove_dir_all(format!("{}/{}", self.config().model_dir.clone(), model_id)).map_err(Into::into)
    }

    pub async fn get_all_models(&self) -> anyhow::Result<Vec<String>> {
        Ok(std::fs::read_dir(&self.config().model_dir)?
            .filter_map(|entry| entry.ok().filter(|entry| entry.path().is_dir()))
            .filter_map(|entry| {
                entry
                    .path()
                    .file_name()
                    .map(|path| path.to_os_string().into_string().ok())
                    .flatten()
                    .and_then(|name| {
                        let status = self.check_model_directory(&name);
                        if status.is_ok() {
                            Some(name)
                        } else {
                            None
                        }
                    })
            })
            .collect())
    }

}