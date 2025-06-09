use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::DbUtils;





#[derive(Debug, Serialize, Deserialize, Clone, Default)]
pub struct Embedding {
    changed: bool,
    vectors: Vec<f32>
}

#[derive(Debug, Serialize, Deserialize, Clone, Default)]
pub struct EmbeddingDiff {
    pub id: Uuid,
    pub content: String,
    pub title: String
}

#[derive(Debug, Serialize, Deserialize, Clone, Default)]
pub struct EmbeddingOfNote {
    pub id: Uuid,
    pub vectors: Vec<f32>
}

impl DbUtils for Embedding {
    const TABLE: &'static str = "embedding";
}