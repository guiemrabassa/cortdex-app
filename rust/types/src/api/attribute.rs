use std::collections::{HashMap, HashSet};

use chrono::NaiveDateTime;

use flutter_rust_bridge::frb;
use serde::{Deserialize, Serialize};
use serde_json::{Value, json};
use uuid::Uuid;

use crate::DbUtils;

#[derive(Clone, Copy, Serialize, Deserialize, Debug)]
pub enum AttributeKind {
    Object,
    Text,
    Number,
    Select,
    MultiSelect,
    Checkbox,
    Datetime,
    Date,
    Time
}

impl ToString for AttributeKind {
    fn to_string(&self) -> String {
        match self {
            Self::Object => "object".to_owned(),
            Self::Text => "text".to_owned(),
            Self::Number => "number".to_owned(),
            Self::Select => "select".to_owned(),
            Self::MultiSelect => "multiselect".to_owned(),
            Self::Checkbox => "checkbox".to_owned(),
            Self::Datetime => "datetime".to_owned(),
            Self::Date => "date".to_owned(),
            Self::Time => "time".to_owned()
        }
    }
}

impl AttributeKind {
    #[frb(sync)]
    pub fn from_string(string: String) -> Option<Self> {
        Some(match string.to_lowercase().as_str() {
            "object" => Self::Object,
            "text" => Self::Text,
            "number" => Self::Number,
            "select" => Self::Select,
            "multiselect" => Self::MultiSelect,
            "checkbox" => Self::Checkbox,
            "datetime" => Self::Datetime,
            "date" => Self::Date,
            "time" => Self::Time,
            _ => return None,
        })
    }
}

#[derive(Clone, Serialize, Deserialize, Debug, PartialEq)]
#[frb(non_opaque)]
#[serde(untagged)]
pub enum AttributeValue {
    Object(Uuid),
    Text(String),
    Number(f64),
    Select(String),
    MultiSelect(HashSet<String>),
    Checkbox(bool),
    Datetime(NaiveDateTime),
    Date(NaiveDateTime),
    Time(NaiveDateTime)
}

impl AttributeValue {
    #[frb(ignore)]
    pub fn inner_as_json(&self) -> (&str, Value) {
        match self {
            Self::Text(s) => ("Text", json!(s)),
            Self::Number(f) => ("Number", json!(f)),
            Self::Select(v) => ("Select", json!(v)),
            Self::MultiSelect(v) => ("MultiSelect", json!(v)),
            Self::Checkbox(b) => ("Checkbox", json!(b)),
            Self::Datetime(d) => ("Datetime", json!(d)),
            Self::Date(d) => ("Date", json!(d)),
            Self::Time(t) => ("Time", json!(t)),
            Self::Object(uuid) => ("Object", json!(uuid)),
        }
    }

    pub fn kind(&self) -> AttributeKind {
        match self {
            Self::Object(_) => AttributeKind::Object,
            Self::Text(_) => AttributeKind::Text,
            Self::Number(_) => AttributeKind::Number,
            Self::Select(_) => AttributeKind::Select,
            Self::MultiSelect(_) => AttributeKind::MultiSelect,
            Self::Checkbox(_) => AttributeKind::Checkbox,
            Self::Datetime(_) => AttributeKind::Datetime,
            Self::Date(_) => AttributeKind::Date,
            Self::Time(_) => AttributeKind::Time,
        }
    }
}

#[derive(Clone, Serialize, Deserialize, Debug)]
#[frb]
pub struct Attribute {
    pub name: String,
    pub kind: AttributeKind,
    pub options: Option<HashSet<String>>,
}

impl DbUtils for Attribute {
    const TABLE: &'static str = "attribute";
}

impl From<AttributeWithValue> for Attribute {
    fn from(value: AttributeWithValue) -> Self {
        Self {
            name: value.name,
            kind: value.kind,
            options: value.options,
        }
    }
}

#[derive(Clone, Serialize, Deserialize, Debug)]
#[frb(unignore)]
pub struct AttributeWithValue {
    pub name: String,
    pub kind: AttributeKind,
    pub options: Option<HashSet<String>>,
    pub value: AttributeValue,
    pub note_id: Uuid,
}

#[derive(Clone, Serialize, Deserialize, Debug)]
#[frb(non_opaque)]
pub enum AttributeCommand {
    AddToNote {
        note_id: Uuid,
        attribute_name: String,
        attribute_value: AttributeValue,
    },
    AddToSelectable {
        attribute_name: String,
        new_selectable: String,
    },
    Create {
        def: Attribute,
    },
    Get {
        name: String,
    },
    GetAllFromNote {
        note_id: Uuid,
    },
    GetAllFromSelectable {
        attribute_name: String,
    },
    GetFromNote {
        note_id: Uuid,
        name: String,
    },
    RemoveFromNote {
        note_id: Uuid,
        name: String,
    },
    Search {
        amount: usize,
        query: String,
        desc: bool,
    },
    UpdateValueOnNote {
        note_id: Uuid,
        attribute_name: String,
        attribute_value: AttributeValue,
    },
}

// TODO:

mod todo {
    use std::collections::HashMap;

    use chrono::NaiveDateTime;
    use serde::{Deserialize, Serialize};

    use super::{Attribute, AttributeValue};

    #[derive(Clone, Serialize, Deserialize, Debug)]
    pub struct NoteAttributeMap {
        #[serde(flatten)]
        pub map: HashMap<String, AttributeValue>,
    }

    #[derive(Clone, Serialize, Deserialize, Debug, PartialEq, PartialOrd)]
    pub struct Reminder {
        pub local_id: i32,
        pub name: String,
        pub recurrent: bool,
        pub date: NaiveDateTime,
    }

    #[derive(Clone, Serialize, Deserialize, Debug)]
    pub struct ObjectType {
        pub id: String,
        pub attributes: Vec<Attribute>,
        // pub layouts: Vec<String>
    }

    impl ObjectType {
        pub fn new(id: String) -> Self {
            ObjectType {
                id,
                attributes: Default::default(),
            }
        }
    }
}
