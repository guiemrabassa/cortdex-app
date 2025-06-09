use std::sync::Arc;

use anyhow::Context;
use axum::http::Uri;
use cortdex_db::api::DbPath;

use futures::StreamExt;
use log::debug;
use reqwest::{
    cookie::{self, CookieStore, Jar},
    header, Url,
};

use tokio_tungstenite::{connect_async, tungstenite::ClientRequestBuilder};

use crate::{
    api::error::{CortdexContext, CortdexError},
    inner::server::{auth::Credentials, ServerResponse},
};

use super::{command::ConcreteCortdexCommand, core::CortdexCore, websockets::CustomWsSplitStream};

pub struct CortdexLocalClient {
    pub core: CortdexCore
}


impl CortdexLocalClient {

    pub async fn new(db_path: DbPath, path: String) -> Result<Self, CortdexError> {
        Ok(Self { core: CortdexCore::new(db_path, path).await? })
    }

    pub async fn process_command(&self, command: ConcreteCortdexCommand) -> Result<Option<String>, CortdexError> {
        let inner = command.0;
        self.core.process_command(inner).await
    }

    pub fn core(&self) -> &CortdexCore {
        &self.core
    }

}

pub struct CortdexRemoteClient {
    pub url: Url,
    client: reqwest::Client,
    cookies: Arc<Jar>,
}

impl CortdexRemoteClient {
    pub async fn inner_connect(url: Url) -> Result<CortdexRemoteClient, CortdexError> {
        debug!("Starting client!");
        let cookies = Arc::new(cookie::Jar::default());

        let client = reqwest::Client::builder()
            .cookie_provider(cookies.clone())
            .build()?;

        let login_response = client
            .post(
                url.clone()
                    .join("login")
                    .cortdex_context("Failed to join login url")?,
            )
            .form(&Credentials::new("Guiem".to_string(), "1234".to_string()))
            .send()
            .await?;

        if login_response.status().is_server_error() || login_response.status().is_client_error() {
            return Err(CortdexError::DetailedError(String::from(
                "Login failed, please check your credentials",
            )));
        }

        debug!("Login successful!");

        Ok(CortdexRemoteClient {
            url,
            client,
            cookies,
        })
    }

    pub async fn process_command(&self, command: ConcreteCortdexCommand) -> Result<Option<String>, CortdexError> {
        let request = self
            .client
            .request(
                reqwest::Method::POST,
                self.url
                    .join("command")
                    .cortdex_context("Failed to join endpoint to url")?,
            )
            .json(&command.0);

        debug!("Requesting: {request:?}");

        let response = request.send().await?;

        debug!("Response received: {response:?}");

        let server_response = response.json::<ServerResponse>().await?;
        
        match server_response {
            ServerResponse::Err(err) => Err(CortdexError::DetailedError(err)),
            ServerResponse::Packet(packet) => Ok(packet),
        }
    }

    pub async fn build_stream(
        &self,
        path: String,
        query: Option<(String, String)>,
    ) -> Result<CustomWsSplitStream, CortdexError> {
        debug!("Trying to build ws stream for endpoint: {path}");

        // Get the base url, set it to websocket scheme and path, add query params if provided
        let mut url = self.url.clone();
        let _ = url.set_scheme("ws");
        url.set_path(path.as_str());

        if let Some((name, value)) = query {
            url.query_pairs_mut().append_pair(&name, &value);
        }

        debug!("Built ws url: {url:?}");

        let uri: Uri = url
            .as_str()
            .parse()
            .cortdex_context("Failed to parse stream uri")?;

        debug!("Built ws uri: {uri:?}");

        // Get the session cookies from the store to add them to the request
        let cookies = self
            .cookies
            .cookies(&self.url)
            .context("Failed to get cookies from url")?;

        let cookies_str = cookies
            .to_str()
            .cortdex_context("Failed to convert cookies to string")?;

        let req = ClientRequestBuilder::new(uri).with_header(header::COOKIE.as_str(), cookies_str);

        debug!("Built ws request builder: {req:?}");

        let (stream, _) = connect_async(req).await?;
        let (writer, reader) = stream.split();

        debug!("Built ws stream for endpoint: {path}");

        Ok(CustomWsSplitStream {
            writer,
            reader: Some(reader),
            close: None
        })
    }
}
