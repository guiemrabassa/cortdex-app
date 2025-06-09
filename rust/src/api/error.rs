use std::fmt::{Debug, Display};

use axum::response::IntoResponse;
use flutter_rust_bridge::frb;
use reqwest::StatusCode;
use thiserror::Error;
use tokio_tungstenite::tungstenite;

#[frb]
#[derive(Error, Debug)]
pub enum CortdexError {
    #[error("Failed to connect to WebSocket server: {0}")]
    ConnectionError(#[from] tungstenite::Error),

    #[error("Failed to send command to server: {0}")]
    CommandSendError(String),

    #[error("{0}")]
    Db(#[from] cortdex_db::api::error::CortdexDbError),

    #[error("Failed to receive response from server: {0}")]
    ResponseReceiveError(#[from] tokio::sync::oneshot::error::RecvError),

    #[error("Failed to serialize or deserialize data: {0}")]
    SerializationError(#[from] serde_json::Error),

    #[error("Failed to embed text: {0}")]
    EmbeddingError(#[from] cortdex_ml::error::EmbeddingError),

    #[error("{0}")]
    Error(#[from] anyhow::Error),

    #[error("{0}")]
    AxumConnectionError(#[from] axum::Error),

    #[error("Request error: {0}")]
    ReqwestError(#[from] reqwest::Error),

    #[error("The read stream is not available right now!")]
    ReadStreamNotAvailable,

    #[error("{0}")]
    DetailedError(String),

    #[error("Unexpected error occurred")]
    UnexpectedError,
}

impl CortdexError {
    #[frb(sync)]
    pub fn get_message(self) -> String {
        self.to_string()
    }
}

pub trait CortdexContext<T, E> {
    fn cortdex_context<C>(self, context: C) -> Result<T, CortdexError>
    where
        C: Display + Send + Sync + 'static;

        // TODO: Check
    /* /// Wrap the error value with additional context that is evaluated lazily
    /// only once an error does occur.
    fn with_context<C, F>(self, f: F) -> Result<T, Error>
    where
        C: Display + Send + Sync + 'static,
        F: FnOnce() -> C; */
}

impl<T, E> CortdexContext<T, E> for Result<T, E>
where
    E: Send + Sync + 'static + Display,
{
    fn cortdex_context<C>(self, context: C) -> Result<T, CortdexError>
    where
        C: Display + Send + Sync + 'static,
    {
        match self {
            Ok(ok) => Ok(ok),
            Err(error) => {
                let message = format!("Cortdex Error: \n{}\n Caused by: \n{}", context, error);
                Err(CortdexError::DetailedError(message))
            }
        }
    }
}

impl<T, E> CortdexContext<T, E> for Option<T>
where
    E: Send + Sync + 'static,
{
    fn cortdex_context<C>(self, context: C) -> Result<T, CortdexError>
    where
        C: Display + Send + Sync + 'static,
    {
        match self {
            Some(content) => Ok(content),
            None => Err(CortdexError::DetailedError(format!("{context}"))),
        }
    }
}

impl IntoResponse for CortdexError {
    fn into_response(self) -> axum::response::Response {
        StatusCode::BAD_REQUEST.into_response()
    }
}
