use cortdex_db::api::DbPath;
use rust_lib_cortdex::{
    api::ServerSettings,
    inner::server::{CortdexServer},
};

use log::{info, log};

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let mac_os = "/Users/guiem/Library/Containers/com.example.cortdex/Data/Documents/cortdex/";

    let (tx, rx) = tokio::sync::oneshot::channel::<()>();

    if std::env::var_os("RUST_LOG").is_none() {
        unsafe { std::env::set_var("RUST_LOG", "debug") };
    }

    let settings = ServerSettings {
        port: 9002,
        db_path: DbPath::Remote {
            address: String::from("localhost"),
            port: 80,
        },
        model_path: mac_os.to_string(),
    };

    env_logger::init();    

    info!("Hello");

    let _ = CortdexServer::create(settings, rx).await?;

    Ok(())
}
