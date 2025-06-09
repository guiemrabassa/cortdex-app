use cortdex_types::embedding::{EmbeddingDiff, EmbeddingOfNote};

use crate::error::EmbeddingError;






pub trait Embedder {

    fn get_embeddings(&self, text: String) -> Result<Vec<f32>, EmbeddingError>;

    fn calc_embeddings(&self, diffs: Vec<EmbeddingDiff>) -> Vec<EmbeddingOfNote>;

}