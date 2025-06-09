use std::collections::HashMap;

use gix::{create::{Kind, Options}, ThreadSafeRepository};
use log::debug;

#[derive(Clone)]
pub struct VaultManager {
    main_dir: String,
    vaults: HashMap<String, Vault>
}

#[derive(Clone)]
pub struct Vault {
    repo: ThreadSafeRepository
}

impl VaultManager {

    pub fn start(main_dir: String) -> VaultManager {
        let _ = std::fs::create_dir_all(format!("{}/vaults", main_dir));
        VaultManager { main_dir, vaults: HashMap::default() }
    }

    pub fn list_all_vaults(&self) -> Vec<String> {
        Vec::new()
    }

    // TODO: The difference here is that this method makes the program be constantly aware, while init_vault only inits it
    pub fn load_vault(&mut self, name: String) -> anyhow::Result<()> {
        let path = format!("{}/vaults/{name}", self.main_dir);

        let repo = ThreadSafeRepository::open(path)?;

        self.vaults.insert(name, Vault { repo });

        Ok(())
    }

    pub fn init_vault(&mut self, name: String) -> anyhow::Result<()> {
        let path = format!("{}/vaults/{name}", self.main_dir);

        let a = ThreadSafeRepository::init(path, Kind::WithWorktree, Options {
            destination_must_be_empty: false,
            fs_capabilities: None,
        });

        debug!("Initiating vault: {a:?}");

        Ok(())
    }

}

