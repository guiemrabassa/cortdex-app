use std::collections::HashMap;

use axum::{
    response::IntoResponse, Form
};
use axum_login::{AuthManagerLayerBuilder, AuthSession, AuthUser, AuthnBackend, UserId};
use log::debug;
use reqwest::StatusCode;
use serde::{Deserialize, Serialize};
use tower_sessions::{cookie::SameSite, Expiry, MemoryStore, SessionManagerLayer};

use crate::api::error::CortdexError;

#[derive(Clone, Serialize, Deserialize)]
pub struct User {
    id: i64,
    pub username: String,
    password: String,
}

impl User {
    pub fn new(id: i64, username: &str, password: &str) -> User {
        User {
            id,
            username: username.to_string(),
            password: password.to_string(),
        }
    }
}

impl std::fmt::Debug for User {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("User")
            .field("id", &self.id)
            .field("username", &self.username)
            .field("password", &"[redacted]")
            .finish()
    }
}

impl AuthUser for User {
    type Id = String;

    fn id(&self) -> Self::Id {
        self.username.clone()
    }

    fn session_auth_hash(&self) -> &[u8] {
        self.password.as_bytes()
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Credentials {
    pub username: String,
    pub password: String,
    pub next: Option<String>,
}

impl Credentials {
    pub fn new(username: String, password: String) -> Credentials {
        Credentials {
            username,
            password,
            next: None,
        }
    }
}

#[derive(Debug, Clone, Default)]
pub struct Backend {
    pub db: HashMap<String, User>,
}

impl AuthnBackend for Backend {
    type User = User;

    type Credentials = Credentials;

    type Error = CortdexError;

    async fn authenticate(
        &self,
        creds: Self::Credentials,
    ) -> Result<Option<Self::User>, Self::Error> {
        Ok(self.db.get(&creds.username).cloned())
    }

    async fn get_user(&self, user_id: &UserId<Self>) -> Result<Option<Self::User>, Self::Error> {
        Ok(self.db.get(user_id).cloned())
    }
}

pub async fn login_post(
    mut auth_session: AuthSession<Backend>,
    Form(creds): Form<Credentials>,
) -> impl IntoResponse {
    debug!("Login attempt with creds: {:?}", creds);

    let user = match auth_session.authenticate(creds.clone()).await {
        Ok(Some(user)) => user,
        Ok(None) => return StatusCode::UNAUTHORIZED.into_response(),
        Err(_) => return StatusCode::INTERNAL_SERVER_ERROR.into_response(),
    };

    if auth_session.login(&user).await.is_err() {
        return StatusCode::INTERNAL_SERVER_ERROR.into_response();
    }

    debug!("User logged in: {:?}", user);

    StatusCode::OK.into_response()
}

#[derive(Debug, Deserialize)]
pub struct NextUrl {
    next: Option<String>,
}

pub fn auth_layer() -> axum_login::AuthManagerLayer<Backend, MemoryStore> {
    let session_store = MemoryStore::default();
    let session_layer = SessionManagerLayer::new(session_store)
        .with_secure(false)
        .with_same_site(SameSite::Lax) // Ensure we send the cookie from the OAuth redirect.
        .with_expiry(Expiry::OnInactivity(tower_sessions::cookie::time::Duration::days(1)));

    let mut backend = Backend::default();
    backend
        .db
        .insert("Guiem".to_string(), User::new(0, "Guiem", "1234"));

    let auth_layer = AuthManagerLayerBuilder::new(backend, session_layer).build();
    auth_layer
}