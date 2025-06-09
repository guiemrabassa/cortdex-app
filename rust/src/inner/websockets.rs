
use axum::extract::ws::WebSocket;
use futures::SinkExt;
use futures::StreamExt;





use futures::stream::SplitStream;

use futures::stream::SplitSink;

use tokio::net::TcpStream;

use tokio_tungstenite::MaybeTlsStream;
use tokio_tungstenite::WebSocketStream;

use crate::api::error::CortdexError;

use super::stream::CortdexMessage;
use super::stream::CortdexReaderExt;
use super::stream::CortdexStreamExt;
use super::stream::CortdexWriterExt;



pub type WsStream = WebSocketStream<MaybeTlsStream<TcpStream>>;

pub type WsWriter = SplitSink<WsStream, tokio_tungstenite::tungstenite::Message>;

pub type WsReader = SplitStream<WsStream>;

impl<T: CortdexMessage> CortdexWriterExt<T> for WsStream {
    async fn send_text(&mut self, text: String) -> Result<(), CortdexError> {
        self.send(tokio_tungstenite::tungstenite::Message::text(text)).await.map_err(Into::into)
    }

    async fn send_object(
        &mut self,
        object: T,
    ) -> Result<(), CortdexError> {
        self.send(tokio_tungstenite::tungstenite::Message::text(serde_json::to_string(&object)?))
            .await
            .map_err(Into::into)
    }
}

impl<T: CortdexMessage> CortdexReaderExt<T> for WsStream {
    async fn next_as(&mut self) -> Result<T, CortdexError> {
        if let tokio_tungstenite::tungstenite::Message::Text(text) = self.next().await.ok_or(CortdexError::UnexpectedError)?? {
            serde_json::from_str::<T>(&text).map_err(Into::into)
        } else {
            Err(CortdexError::UnexpectedError)
        }
    }
}

impl<T: CortdexMessage> CortdexStreamExt<T> for WsStream {
    fn split_into(self) -> Result<(impl CortdexWriterExt<T>, impl tokio_stream::StreamExt), CortdexError> {
        Ok(self.split())
    }
}


impl<T: CortdexMessage> CortdexWriterExt<T> for WebSocket {
    async fn send_text(&mut self, text: String) -> Result<(), CortdexError> {
        self.send(axum::extract::ws::Message::text(text)).await.map_err(Into::into)
    }

    async fn send_object(
        &mut self,
        object: T,
    ) -> Result<(), CortdexError> {
        self.send(axum::extract::ws::Message::text(serde_json::to_string(&object)?))
            .await
            .map_err(Into::into)
    }
}

impl<T: CortdexMessage> CortdexReaderExt<T> for WebSocket {
    async fn next_as(&mut self) -> Result<T, CortdexError> {
        if let axum::extract::ws::Message::Text(text) = self.next().await.ok_or(CortdexError::UnexpectedError)?? {
            serde_json::from_str::<T>(&text).map_err(Into::into)
        } else {
            Err(CortdexError::UnexpectedError)
        }
    }
}

impl<T: CortdexMessage> CortdexStreamExt<T> for WebSocket {
    fn split_into(self) -> Result<(impl CortdexWriterExt<T>, impl tokio_stream::StreamExt), CortdexError> {
        Ok(self.split())
    }
}

impl<T: CortdexMessage> CortdexReaderExt<T> for SplitStream<axum::extract::ws::WebSocket> {
    async fn next_as(&mut self) -> Result<T, CortdexError> {
        if let axum::extract::ws::Message::Text(text) = self.next().await.ok_or(CortdexError::UnexpectedError)?? {
            serde_json::from_str::<T>(&text).map_err(Into::into)
        } else {
            Err(CortdexError::UnexpectedError)
        }
    }
}

impl<T: CortdexMessage> CortdexWriterExt<T> for SplitSink<axum::extract::ws::WebSocket, axum::extract::ws::Message> {
    async fn send_text(&mut self, text: String) -> Result<(), CortdexError> {
        self.send(axum::extract::ws::Message::text(text)).await.map_err(Into::into)
    }

    async fn send_object(
        &mut self,
        object: T,
    ) -> Result<(), CortdexError> {
        self.send(axum::extract::ws::Message::text(serde_json::to_string(&object)?))
            .await
            .map_err(Into::into)
    }
}


impl<T: CortdexMessage> CortdexWriterExt<T> for WsWriter {
    async fn send_text(&mut self, text: String) -> Result<(), CortdexError> {
        self.send(tokio_tungstenite::tungstenite::Message::text(text)).await.map_err(Into::into)
    }

    async fn send_object(&mut self, object: T) -> Result<(), CortdexError> {
        self.send(tokio_tungstenite::tungstenite::Message::text(serde_json::to_string(&object)?))
            .await
            .map_err(Into::into)
    }
}

impl<T: CortdexMessage> CortdexReaderExt<T> for WsReader {
    async fn next_as(&mut self) -> Result<T, CortdexError> {
        if let tokio_tungstenite::tungstenite::Message::Text(text) = self.next().await.ok_or(CortdexError::UnexpectedError)?? {
            serde_json::from_str::<T>(&text).map_err(Into::into)
        } else {
            Err(CortdexError::UnexpectedError)
        }
    }
}

// #[derive(Delegate)]
// #[delegate(CortdexWriterExt, target = "writer")]
// #[delegate(CortdexReaderExt, target = "reader")] TODO: implement this
pub struct CustomWsSplitStream {
    pub writer: WsWriter,
    pub reader: Option<WsReader>,
    pub close: Option<tokio::sync::oneshot::Sender<()>>,
}