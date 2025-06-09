use flutter_rust_bridge::frb;
use serde::{Deserialize, Serialize};
use surrealdb::RecordId;
use uuid::Uuid;

use crate::DbUtils;


#[frb(ignore)]
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct NoteWithId {
    pub id: RecordId,
    pub title: String,
    pub content: String,
    pub path: String,
}

impl TryFrom<NoteWithId> for Note {
    type Error = anyhow::Error;

    fn try_from(value: NoteWithId) -> Result<Self, Self::Error> {
        match value.id.into_inner().id {
            surrealdb::sql::Id::Uuid(uuid) => Ok(Self {
                id: uuid.0,
                title: value.title,
                content: value.content,
                path: value.path,
            }),
            _ => Err(anyhow::Error::msg(
                "Expected a UUID in the NoteWithId struct",
            )), // Return a clear error for invalid cases
        }
    }
}

impl From<Note> for NoteWithId {
    fn from(value: Note) -> Self {
        Self {
            id: RecordId::from_table_key("note", value.id),
            title: value.title,
            content: value.content,
            path: value.path,
        }
    }
}

// #[frb(dart_metadata=("freezed"), json_serializable)]
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Note {
    /* #[serde(
        serialize_with = "serialize_record_id",
        deserialize_with = "deserialize_record_id"
    )] */
    pub id: Uuid,
    pub title: String,
    pub content: String,
    pub path: String,
}

impl Note {
    #[frb(sync)]
    pub fn new(title: String, content: String) -> Self {
        Self {
            id: Uuid::now_v7(),
            title: title.clone(),
            content,
            path: title, // TODO: Add the id?
        }
    }

    #[frb(sync)]
    pub fn with_path(title: String, content: String, path: String) -> Self {
        Self {
            id: Uuid::now_v7(),
            title: title.clone(),
            content,
            path,
        }
    }

}

impl DbUtils for Note {
    const TABLE: &'static str = "note";
}

impl Default for Note {
    #[frb(sync)]
    fn default() -> Self {
        Note::new(
            String::from("New Note"),
            String::new(),
        )
    }
}

#[frb(non_opaque)]
#[derive(Clone, Serialize, Deserialize, Debug)]
pub struct NoteEditingCommand {
    pub delta: String,
    pub markdown: String,
}

#[frb]
#[derive(Clone, Serialize, Deserialize, Debug)]
#[frb(non_opaque)]
pub enum NoteCommand {
    ChangeTitle { id: Uuid, new_title: String },
    ChangeContent { id: Uuid, new_content: String },
    Create,
    Get { id: Uuid },
    Delete { id: Uuid },
}

#[frb]
#[derive(Clone, Serialize, Deserialize, Debug)]
#[frb(non_opaque)]
pub enum NoteQuery {
    Basic { amount: usize, text: String },
    Full { amount: usize, text: String }
}