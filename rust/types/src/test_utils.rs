use std::{env, path::PathBuf};

use flutter_rust_bridge::frb;





#[frb(ignore)]
pub fn get_test_path() -> PathBuf {
    let manifest_dir = env::var("CARGO_MANIFEST_DIR").expect("CARGO_MANIFEST_DIR not set");
    PathBuf::from(manifest_dir).join("../assets")
}