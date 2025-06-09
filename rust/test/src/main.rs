

use cortdex_ml::{api::manager::ModelManagerConfig, manager::ModelManager};

use notify::Watcher;
use std::env::current_dir;


mod ml;
mod fs;


mod database;

// Example for the pollwatcher scan callback feature.
// Returns the scanned paths
#[tokio::main]
async fn main() -> anyhow::Result<()> {

    download_in_assets().await

    // ml_download_test().await;
    // git_test();
    // git_test();

/* 
    let path = std::env::args()
        .nth(1)
        .expect("Argument 1 needs to be a path");

    // let _ = read_note_from_file(path);
    // let _ = read_dir(path);

    
    let note = NewNote::from_file_string(path);
    println!("Read note: {:?}", note); */

    /* if let Err(error) = watch(path) {
        eprintln!("Error: {error:?}");
    } */
}

async fn download_in_assets() -> anyhow::Result<()> {
    let dir = current_dir()?;

    let mm = ModelManager::new(ModelManagerConfig::new_basic(format!("{}/assets", dir.display()).to_string()));

    let download = mm.download_new_model("sentence-transformers/all-MiniLM-L6-v2".to_string()).await;

    println!("Download result: {download:?}");

    Ok(())
}