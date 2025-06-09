use core::fmt;

use ambassador::{delegatable_trait, Delegate};
use anyhow::Context;

use futures::Stream;
use serde::{de::DeserializeOwned, Serialize};
use tokio::sync::mpsc::{channel, Sender};
use tokio_stream::{wrappers::ReceiverStream, StreamExt};


use crate::api::error::CortdexError;


pub trait CortdexMessage: Serialize + fmt::Debug + DeserializeOwned + Clone + Send + Sync + Unpin + 'static {}

impl<T: Serialize + fmt::Debug + DeserializeOwned + Clone + Send + Sync + Unpin + 'static> CortdexMessage for T {}

pub trait CortdexStreamExt<T: CortdexMessage> {

    fn split_into(self) -> Result<(impl CortdexWriterExt<T>, impl StreamExt), CortdexError>;

}

#[delegatable_trait]
pub trait CortdexReaderExt<T: CortdexMessage>: StreamExt + Stream + Unpin {

    async fn next_as(&mut self) -> Result<T, CortdexError>;

}

#[delegatable_trait]
pub trait CortdexWriterExt<T: CortdexMessage> {

    async fn send_text(&mut self, text: String) -> Result<(), CortdexError>;
    async fn send_object(
        &mut self,
        object: T,
    ) -> Result<(), CortdexError>;

}


impl<T: CortdexMessage> CortdexWriterExt<T> for Sender<T> {

    async fn send_text(&mut self, text: String) -> Result<(), CortdexError> {
        let object: T = serde_json::from_str(&text).context("Could not parse text as object")?;
        self.send(object).await.context("Could not send text to client").map_err(Into::into)
    }

    async fn send_object(
        &mut self,
        object: T,
    ) -> Result<(), CortdexError> {
        self.send(object).await.context("Could not send object to client").map_err(Into::into)
    }
}


impl<T: CortdexMessage> CortdexReaderExt<T> for ReceiverStream<T> {
    async fn next_as(&mut self) -> Result<T, CortdexError> {
        self.next().await.context("Could not deserialize object on receival").map_err(Into::into)
    }
}

#[derive(Delegate)]
#[delegate(CortdexWriterExt<T>, target = "sender")]
// #[delegate(CortdexReaderExt<T>, target = "receiver")]
pub struct CortdexStream<T: CortdexMessage> {
    pub sender: Sender<T>,
    pub receiver: Option<ReceiverStream<T>>,
    pub close: Option<tokio::sync::oneshot::Sender<()>>,
}

impl<T: CortdexMessage> CortdexStream<T> {

    pub fn new() -> Self {
        let (sender, receiver) = channel(10);

        Self { sender, receiver: Some(ReceiverStream::new(receiver)), close: None }
    }
    
}
/* 
impl<T: CortdexMessage> CortdexReaderExt<T> for CortdexStream<T> {
    async fn next_as(&mut self) -> Result<T, CortdexError> {
        if let Some(receiver) = &mut self.receiver {
            receiver.next_as().await
        } else {
            Err(CortdexError::ReadStreamNotAvailable)
        }
    }
} */



impl<T: CortdexMessage> CortdexStreamExt<T> for CortdexStream<T> {

    fn split_into(self) -> Result<(impl CortdexWriterExt<T>, impl StreamExt), CortdexError> {
        Ok((self.sender, self.receiver.context("Receiver not present")?))
    }

}