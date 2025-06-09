use std::net::{Ipv4Addr, SocketAddr};

use anyhow::Context;
use auth::{Backend, auth_layer, login_post};
use axum::extract::State;
use axum::response::IntoResponse;
use axum::routing::{any, post};
use axum::{Json, Router};
use axum_login::login_required;
use flutter_rust_bridge::frb;
use log::debug;


use reqwest::StatusCode;
use serde::{Deserialize, Serialize};
use tokio::sync::oneshot::Sender;

use super::command::ConcreteInnerCortdexCommand;
use super::core::ServerState;
use crate::api::ServerSettings;
use crate::api::error::CortdexError;

pub mod auth;

#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord)]
pub enum ServerStatus {
    Starting,
    Running,
    Stopping,
    Stopped,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord)]
pub enum ServerCommands {
    Status(ServerStatus),
    Stop,
}

#[frb(opaque)]
pub struct CortdexServer {
    stopper: Option<Sender<()>>,
}

impl CortdexServer {
    pub fn is_running(&self) -> bool {
        self.stopper.is_some()
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum ServerResponse {
    Err(String),
    Packet(Option<String>),
}

pub async fn command(
    State(state): State<ServerState>,
    Json(command): Json<ConcreteInnerCortdexCommand>,
) -> impl IntoResponse {
    debug!("Received command: {command:?}");

    let state = state.clone();

    // TODO: Rework to send the error as well

    let packet = match state.core.process_command(command).await {
        Ok(packet) => ServerResponse::Packet(packet),
        Err(err) => ServerResponse::Err(err.get_message()),
    };

    serde_json::to_string(&packet)
        .map_err(|err| (StatusCode::NOT_FOUND))
        .map(|packet| (StatusCode::FOUND, packet))
        .unwrap()
}

impl CortdexServer {

    #[frb(ignore)]
    pub async fn create(settings: ServerSettings, rx: tokio::sync::oneshot::Receiver<()>) -> anyhow::Result<()> {
        let state = ServerState::new(settings.db_path, settings.model_path).await?;
        let login_router = Router::new().route("/login", post(login_post));
        let base_router = Router::new()
            .route("/command", any(command));

        let app = base_router
            .route_layer(login_required!(Backend, login_url = "/login"))
            .merge(login_router)
            .layer(auth_layer())
            .with_state(state);

        let listener = tokio::net::TcpListener::bind(SocketAddr::new(
            std::net::IpAddr::V4(Ipv4Addr::new(127, 0, 0, 1)),
            settings.port,
        ))
        .await?;

        debug!("Server listening on {}", listener.local_addr()?);

        axum::serve(
            listener,
            app.into_make_service_with_connect_info::<SocketAddr>(),
        )
        .with_graceful_shutdown(async {
            rx.await.ok();
        })
        .await
        .context("Failed to start")
    }

    pub async fn start_on_thread(
        settings: ServerSettings
    ) -> Result<CortdexServer, CortdexError> {
        let (tx, rx) = tokio::sync::oneshot::channel::<()>();

        let _ = flutter_rust_bridge::spawn(async move { CortdexServer::create(settings, rx).await });

        Ok(CortdexServer { stopper: Some(tx) })
    }

    pub fn inner_stop(&mut self) -> anyhow::Result<()> {
        if let Some(sender) = self.stopper.take() {
            sender
                .send(())
                .map_err(|_| anyhow::Error::msg("Error trying to stop server"))?;
        }

        Ok(())
    }
}
