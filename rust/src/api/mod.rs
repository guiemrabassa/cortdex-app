use std::env;

use cortdex_ml::{api::manager::ModelManagerConfig, manager::ModelManager};
use error::{CortdexContext, CortdexError};
use flutter_rust_bridge::frb;

use cortdex_db::api::DbPath;
use log::debug;
use note::NoteEditor;
use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::{
    frb_generated::StreamSink,
    inner::{
        client::{CortdexLocalClient, CortdexRemoteClient},
        command::ConcreteCortdexCommand,
        logger,
        server::CortdexServer,
    },
};

pub mod error;
pub mod note;

#[frb(non_opaque, json_serializable)]
#[derive(Clone, PartialEq, Eq, PartialOrd, Ord, Debug, Serialize, Deserialize)]
pub enum ConnectionSettings {
    Embedded {
        db_path: DbPath,
        model_path: String, // TODO: Modify to read from settings maybe? A path for each, with a model manager
    },
    Remote {
        host: String,
        port: u16,
    },
}

#[frb(non_opaque, json_serializable)]
#[derive(Clone, PartialEq, Eq, PartialOrd, Ord, Debug, Serialize, Deserialize)]
pub struct ServerSettings {
    pub port: u16,
    pub db_path: DbPath,
    pub model_path: String,
}

pub struct LogEntry {
    pub time_millis: i64,
    pub level: i32,
    pub tag: String,
    pub msg: String,
}

pub fn create_log_stream(sink: StreamSink<LogEntry>) -> anyhow::Result<()> {
    logger::init_logger(sink);
    Ok(())
}

#[flutter_rust_bridge::frb]
pub async fn init_app(main_dir: String) -> anyhow::Result<()> {
    unsafe { env::set_var("RUST_BACKTRACE", "1") }

    /* let handle = flutter_rust_bridge::spawn(async move {
        loop {
            println!("Hola");
        }
    }); */

    flutter_rust_bridge::setup_default_user_utils();

    Ok(())
}

// #[frb(non_opaque)]
pub enum CortdexClient {
    Local(CortdexLocalClient),
    Remote(CortdexRemoteClient),
}

pub trait IntoConcreteCortexCommand {
    #[frb(sync)]
    fn into_ccd(self) -> ConcreteCortdexCommand;
}

impl CortdexClient {

    #[frb(proxy, sync)]
    pub fn get_mm(&self) -> &ModelManager {
        match self {
            CortdexClient::Local(cortdex_local_client) => &cortdex_local_client.core.model_manager,
            CortdexClient::Remote(cortdex_remote_client) => panic!(),
        }
    }

    #[frb(proxy, sync)]
    pub fn local(&self) -> &CortdexLocalClient {
        match self {
            CortdexClient::Local(cortdex_local_client) => &cortdex_local_client,
            CortdexClient::Remote(cortdex_remote_client) => panic!(),
        }
    }

    #[frb(proxy, sync)]
    pub fn remote(&self) -> &CortdexRemoteClient {
        match self {
            CortdexClient::Local(cortdex_local_client) => panic!(),
            CortdexClient::Remote(cortdex_remote_client) => cortdex_remote_client,
        }
    }

    /* pub async fn get_note_editor(&self, id: Option<Uuid>) -> Result<NoteEditor, CortdexError> {
        match self {
            CortdexClient::Local(cortdex_local_client) => cortdex_local_client.get_note_editor(id).await,
            CortdexClient::Remote(cortdex_remote_client) => cortdex_remote_client.get_note_editor(id).await,
        }
    } */

    #[frb(opaque)]
    pub async fn process_command(
        &self,
        command: ConcreteCortdexCommand,
    ) -> Result<Option<String>, CortdexError> {
        match self {
            CortdexClient::Local(cortdex_local_client) => {
                cortdex_local_client.process_command(command).await
            }
            CortdexClient::Remote(cortdex_remote_client) => {
                cortdex_remote_client.process_command(command).await
            }
        }
    }

    #[frb]
    pub async fn new(kind: ConnectionSettings) -> Result<Self, CortdexError> {
        match kind {
            ConnectionSettings::Embedded {
                db_path,
                model_path,
            } => CortdexLocalClient::new(db_path, model_path)
                .await
                .map(|local| Self::Local(local)),
            ConnectionSettings::Remote { host, port } => CortdexRemoteClient::connect(host, port)
                .await
                .map(|remote| Self::Remote(remote)),
        }
    }
}

/* #[delegatable_trait]
pub trait CortdexClientExt {
    async fn get_note_editor(&self, id: Option<Uuid>) -> Result<NoteEditor, CortdexError>;
} */

impl CortdexLocalClient {
    /* async fn get_note_editor(&self, id: Option<Uuid>) -> Result<NoteEditor, CortdexError> {
        local_note_handler(self.state.clone(), NoteEditingQuery {
            id,
        }).await.map(|stream| NoteEditor::Local(stream))
    } */

    pub fn change_model_manager_config(&mut self, new_config: ModelManagerConfig) {
        self.core.model_manager.change_config(new_config);
    }

    pub async fn load_model(&mut self, model_id: String) -> Result<(), CortdexError> {
        self.core
            .model_manager
            .load_model(model_id)
            .await
            .map_err(Into::into)
    }

    pub async fn download_new_model(&mut self, model_id: String) -> Result<(), CortdexError> {
        self.core
            .model_manager
            .download_new_model(model_id)
            .await
            .map_err(Into::into)
    }

    pub async fn remove_model(&mut self, model_id: String) -> Result<(), CortdexError> {
        self.core
            .model_manager
            .remove_model(model_id)
            .await
            .map_err(Into::into)
    }

    pub async fn get_all_models(&self) -> Result<Vec<String>, CortdexError> {
        self.core
            .model_manager
            .get_all_models()
            .await
            .map_err(Into::into)
    }

    pub fn get_model_manager_config(&self) -> Result<ModelManagerConfig, CortdexError> {
        Ok(self.core.model_manager.config().clone())
    }

}

impl CortdexRemoteClient {
    pub async fn connect(ip: String, port: u16) -> Result<CortdexRemoteClient, CortdexError> {
        debug!("Trying to connect to http://{ip}:{port}/");
        let uri = format!("http://{ip}:{port}/")
            .parse()
            .cortdex_context("Failed to parse connection URL")?;

        Self::inner_connect(uri).await
    }

    async fn get_note_editor(&self, id: Option<Uuid>) -> Result<NoteEditor, CortdexError> {
        self.build_stream(
            String::from("note"),
            id.map(|id| ("id".to_string(), id.to_string())),
        )
        .await
        .map(|remote| NoteEditor::Remote(remote))
    }
}

impl CortdexServer {
    pub async fn start(settings: ServerSettings) -> Result<CortdexServer, CortdexError> {
        Self::start_on_thread(settings).await
    }

    pub fn stop(&mut self) -> anyhow::Result<()> {
        self.inner_stop()
    }
}

pub fn read_markdown_file(path: &str) -> Result<String, CortdexError> {
    std::fs::read_to_string(path)
        .cortdex_context(format!("Failed to read markdown file at {}", path))
}

pub fn write_markdown_file(path: &str, content: &str) -> Result<(), CortdexError> {
    std::fs::write(path, content)
        .cortdex_context(format!("Failed to write markdown file at {}", path))
}
