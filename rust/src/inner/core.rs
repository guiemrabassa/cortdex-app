use std::{ops::Deref, sync::Arc};

use axum::extract::ws::{Message, WebSocket};
use cortdex_db::{api::DbPath, connection::DbConnection};
use cortdex_ml::{
    api::manager::ModelManagerConfig,
    manager::ModelManager,
};
use cortdex_types::api::note::NoteEditingCommand;
use dashmap::DashMap;
use futures::stream::{SplitSink, SplitStream};

use log::debug;
use tokio_stream::StreamExt;
use uuid::Uuid;

use crate::api::error::CortdexError;

use super::{
    command::{ConcreteInnerCortdexCommand, CortdexCommand},
    stream::CortdexWriterExt,
};

pub struct CortdexCore {
    pub db_pool: DbConnection,
    pub model_manager: ModelManager,
}

impl CortdexCore {

    pub async fn new(db_path: DbPath, path: String) -> Result<Self, CortdexError> {
        debug!("Creating new CortdexCore instance with db_path: {:?} and path: {:?}", db_path, path);
        let mut manager = ModelManager::new(ModelManagerConfig::new_basic(path));
        manager.setup().await?;
        Ok(Self {
            db_pool: DbConnection::new(db_path).await?,
            model_manager: manager,
        })
    }

    pub async fn process_command(
        &self,
        command: ConcreteInnerCortdexCommand,
    ) -> Result<Option<String>, CortdexError> {
        // TODO: Maybe move here the serialization of the response?
        // I can't return right now any deserializable object, so String
        command.run(self).await
    }

    

}

#[derive(Clone)]
pub struct ServerState {
    pub core: Arc<CortdexCore>,
}

impl Deref for ServerState {
    type Target = CortdexCore;

    fn deref(&self) -> &Self::Target {
        &self.core
    }
}

impl ServerState {
    pub async fn new(db_path: DbPath, path: String) -> Result<Self, CortdexError> {
        let state = CortdexCore::new(db_path, path).await?;

        Ok(Self { core: Arc::new(state)} )
    }
}
