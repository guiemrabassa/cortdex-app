
use thiserror::Error;

#[derive(Error, Debug)]
pub enum CortdexDbError {
    #[error("{0}")]
    Any(#[from] anyhow::Error),
    #[error("Database error {0}")]
    Surreal(#[from] surrealdb::Error)
}