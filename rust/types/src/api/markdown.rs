use anyhow::Context;
use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::{deserialize_record_id, serialize_record_id};

const FRONT_MATTER_MARKER: &str = "---";

/* impl NewNote {
    pub fn from_file_string(path: String) -> anyhow::Result<NewNote> {
        let file = std::fs::read_to_string(&path)?;

        let split: Vec<&str> = file.split(FRONT_MATTER_MARKER).collect();

        let front_matter = split.get(1).context("Failed to find front matter")?; // Insert it then?

        let parsed_front_matter: FrontMatter = serde_yaml::from_str(front_matter)
            .context("Failed to parse yaml")
            .or(serde_json::from_str(front_matter).context("Failed to parse json"))?;

        Ok(NewNote {
            id: parsed_front_matter.id,
            path,
            map: parsed_front_matter.map,
            content: split.get(2).map(|s| s.to_string()).unwrap_or_default(),
        })
    }
} */
/* 
#[derive(Clone, Serialize, Deserialize, Debug)]
struct FrontMatter {
    pub id: Uuid,
    #[serde(flatten)]
    pub map: NoteAttributeMap,
}

impl FrontMatter {
    pub fn new(front_matter: &str) -> anyhow::Result<Self> {
        serde_yaml::from_str(front_matter)
            .context("Failed to parse yaml")
            .or(serde_json::from_str(front_matter).context("Failed to parse json"))
    }
} */
