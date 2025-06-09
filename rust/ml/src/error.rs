use anyhow::Error;
use thiserror::Error;




#[derive(Error, Debug)]
pub enum EmbeddingError {
    #[error("{0}")]
    CandleError(#[from] candle_core::Error),

    #[error("{0}")]
    ConnectionError(#[from] Error),

    #[error("{0}")]
    TokenizerError(#[from] Box<dyn std::error::Error + Send + Sync>),

    #[error("{0}")]
    SerdeError(#[from] serde_json::Error),

    #[error("{0}")]
    IOError(#[from] std::io::Error),

    #[error("Unexpected error occurred")]
    UnexpectedError,
}


#[derive(Debug, Clone, Default, PartialEq, Eq, PartialOrd, Ord)]
pub enum ModelPartStatus {
    Io(std::io::ErrorKind),
    NotExists,
    #[default]
    Ok,
}

impl ModelPartStatus {
    fn check(path: String) -> ModelPartStatus {
        match std::fs::exists(format!("{}", path)) {
            Ok(exists) => {
                if exists {
                    ModelPartStatus::Ok
                } else {
                    ModelPartStatus::NotExists
                }
            }
            Err(err) => ModelPartStatus::Io(err.kind()),
        }
    }
}

#[derive(Debug, Clone, Default)]
pub struct ModelStatus {
    pub config: ModelPartStatus,
    pub tokenizer: ModelPartStatus,
    pub model: ModelPartStatus,
}

impl ModelStatus {
    /// Check if the directory contains all necessary files
    pub(crate) fn new(dir: &String) -> ModelStatus {
        ModelStatus {
            config: ModelPartStatus::check(format!("{dir}/config.json")),
            tokenizer: ModelPartStatus::check(format!("{dir}/tokenizer.json")),
            model: ModelPartStatus::check(format!("{dir}/model.safetensors")),
        }
    }

    pub fn is_ok(&self) -> bool {
        self.config == ModelPartStatus::Ok
            && self.tokenizer == ModelPartStatus::Ok
            && self.model == ModelPartStatus::Ok
    }
}