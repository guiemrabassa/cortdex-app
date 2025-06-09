use flutter_rust_bridge::frb;
use serde::{Deserialize, Serialize};
use uuid::Uuid;


pub mod git;

// pub mod note;
// pub mod attribute;


#[derive(Debug, Serialize, Deserialize, Clone)]
#[frb(dart_metadata=("freezed", "json_serializable"))]
pub struct UserSettings {
    pub home_page: Option<Uuid>
}


#[derive(Clone, PartialEq, Eq, PartialOrd, Ord, Debug, Serialize, Deserialize)]
#[frb(non_opaque, json_serializable)]
pub enum DbPath {
    Local {
        path: String
    },
    Remote {
        address: String, port: u16
    }
}

pub mod error;