


use candle_core::Tensor;


use crate::error::EmbeddingError;





/* 
pub struct EmbedModel {
    pub model: BertModel,
    pub config: Config,
    pub tokenizer: Tokenizer,
}

impl EmbedModel {
    pub fn new(cpu: bool, path: &str) -> Result<Self, EmbeddingError> {
        let device = candle_examples::device(cpu)?;

        println!("Loading model from {path}");

        let config = read_to_string(format!("{path}/config.json"))?;
        let tokenizer = read_to_string(format!("{path}/tokenizer.json"))?;

        let mut config: Config = serde_json::from_str(&config)?;
        let tokenizer = Tokenizer::from_str(&tokenizer)?;

        let model = read(format!("{path}/model.safetensors"))?;
        let approximate_gelu = false;

        let vb = VarBuilder::from_buffered_safetensors(model, DTYPE, &device)?;

        if approximate_gelu {
            config.hidden_act = HiddenAct::GeluApproximate;
        }

        let model = BertModel::load(vb, &config)?;

        println!("Loaded model from {path}");

        Ok(Self {
            config,
            model,
            tokenizer,
        })
    }

    pub fn get_embeddings(&self, text: String) -> Result<Vec<f32>, EmbeddingError> {
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

        /* let tokens = self.tokenizer
            .with_padding(None)
            .with_truncation(None)
            .map_err(E::msg)?
            .encode(text, true)
            .map_err(E::msg)?;

        let token_ids = Tensor::new(tokens.get_ids().to_vec(), device)?;
        let attention_mask = Tensor::new(tokens.get_attention_mask().to_vec().as_slice(), device)?;
        let token_type_ids = token_ids.zeros_like()?;

        println!("{tokens:?}");
        println!("{token_ids:?}");
        println!("{attention_mask:?}");
        println!("{token_type_ids:?}");

        //Some(&attention_mask)

        let embeddings = self
            .model
            .forward(&token_ids, &token_type_ids, None)?;

            println!("1");
        let (_n_sentence, n_tokens, _hidden_size) = embeddings.dims3()?;
        let embeddings = (embeddings.sum(1)? / (n_tokens as f64))?;

        println!("1");
        let embeddings = if true {
            normalize_l2(&embeddings)?
        } else {
            embeddings
        }; */
        /* println!("1");

        embeddings.to_scalar().map_err(E::msg) */
    }

    pub fn get_batch_embeddings(&self, text: Vec<String>) -> Result<Vec<f32>, EmbeddingError> {
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

        /* let tokens = self.tokenizer
            .with_padding(None)
            .with_truncation(None)
            .map_err(E::msg)?
            .encode(text, true)
            .map_err(E::msg)?;

        let token_ids = Tensor::new(tokens.get_ids().to_vec(), device)?;
        let attention_mask = Tensor::new(tokens.get_attention_mask().to_vec().as_slice(), device)?;
        let token_type_ids = token_ids.zeros_like()?;

        println!("{tokens:?}");
        println!("{token_ids:?}");
        println!("{attention_mask:?}");
        println!("{token_type_ids:?}");

        //Some(&attention_mask)

        let embeddings = self
            .model
            .forward(&token_ids, &token_type_ids, None)?;

            println!("1");
        let (_n_sentence, n_tokens, _hidden_size) = embeddings.dims3()?;
        let embeddings = (embeddings.sum(1)? / (n_tokens as f64))?;

        println!("1");
        let embeddings = if true {
            normalize_l2(&embeddings)?
        } else {
            embeddings
        }; */
        /* println!("1");

        embeddings.to_scalar().map_err(E::msg) */
    }

    /* pub fn run(&self, sentences: Vec<&str>) -> Result<String, EmbeddingError> {
        let device = &self.model.device;
        let n_sentences = sentences.len();

        if let Some(pp) = self.tokenizer.clone().get_padding_mut() {
            pp.strategy = tokenizers::PaddingStrategy::BatchLongest
        } else {
            let pp = PaddingParams {
                strategy: tokenizers::PaddingStrategy::BatchLongest,
                ..Default::default()
            };
            self.tokenizer.clone().with_padding(Some(pp));
        }

        let tokens = self
            .tokenizer
            .encode_batch(sentences.to_vec(), true)
            .map_err(E::msg)?;

        let token_ids = tokens
            .iter()
            .map(|tokens| {
                let tokens = tokens.get_ids().to_vec();
                Ok(Tensor::new(tokens.as_slice(), device)?)
            })
            .collect::<Result<Vec<_>>>()?;

        let attention_mask = tokens
            .iter()
            .map(|tokens| {
                let tokens = tokens.get_attention_mask().to_vec();
                Ok(Tensor::new(tokens.as_slice(), device)?)
            })
            .collect::<Result<Vec<_>>>()?;

        let token_ids = Tensor::stack(&token_ids, 0)?;
        let attention_mask = Tensor::stack(&attention_mask, 0)?;

        let token_type_ids = token_ids.zeros_like()?;

        let embeddings = self
            .model
            .forward(&token_ids, &token_type_ids, Some(&attention_mask))?;

        let (_n_sentence, n_tokens, _hidden_size) = embeddings.dims3()?;
        let embeddings = (embeddings.sum(1)? / (n_tokens as f64))?;

        let embeddings = if true {
            normalize_l2(&embeddings)?
        } else {
            embeddings
        };

        let mut similarities = vec![];

        let e_i = embeddings.get(0)?;

        for i in 1..n_sentences {
            let e_j = embeddings.get(i)?;
            let sum_ij = (&e_i * &e_j)?.sum_all()?.to_scalar::<f32>()?;
            let sum_i2 = (&e_i * &e_i)?.sum_all()?.to_scalar::<f32>()?;
            let sum_j2 = (&e_j * &e_j)?.sum_all()?.to_scalar::<f32>()?;
            let cosine_similarity = sum_ij / (sum_i2 * sum_j2).sqrt();
            similarities.push((cosine_similarity, i))
        }

        similarities.sort_by(|u, v| v.0.total_cmp(&u.0));

        Ok(sentences[similarities.first().unwrap().1].to_string())
    } */
}
 */


fn normalize_l2(v: &Tensor) -> Result<Tensor, EmbeddingError> {
    Ok(v.broadcast_div(&v.sqr()?.sum_keepdim(1)?.sqrt()?)?)
}
