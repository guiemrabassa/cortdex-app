use flutter_rust_bridge::frb;
use serde::{de, Deserialize, Deserializer, Serialize, Serializer};
use surrealdb::sql::Thing;
use uuid::Uuid;


pub mod api;
pub mod test_utils;
pub mod utils;
pub mod embedding;

fn serialize_record_id<S>(id_key: &Uuid, s: S) -> Result<S::Ok, S::Error>
where
    S: Serializer,
{
    surrealdb::RecordId::from_table_key("note", id_key.clone()).serialize(s)
}

pub fn deserialize_record_id<'de, D>(deserializer: D) -> Result<Uuid, D::Error>
where
    D: Deserializer<'de>,
{
    // Attempt to deserialize into a `Thing` object
    let thing = Thing::deserialize(deserializer)?;

    // Extract the UUID from the `Thing::id` field
    match thing.id {
        surrealdb::sql::Id::Uuid(uuid) => Ok(uuid.0), // Return the UUID if it's valid
        _ => Err(de::Error::custom("Expected a UUID in Thing.id")), // Return a clear error for invalid cases
    }
}

#[derive(Serialize, Deserialize, Hash, PartialEq, Eq, PartialOrd, Ord, Debug, Clone, Copy)]
pub struct CortdexUserId(Uuid);

impl Default for CortdexUserId {
    fn default() -> Self {
        CortdexUserId(Uuid::now_v7())
    }
}

#[frb(ignore)]
pub trait DbUtils {

    const TABLE: &'static str;

}


pub trait SerializedResult<E> {

    fn serialized(self) -> Result<Option<String>, E>;

}

impl<T: Serialize, E: std::error::Error> SerializedResult<E> for Result<T, E> {

    fn serialized(self) -> Result<Option<String>, E> {
        self.map(|element| serde_json::to_string(&element).ok())
    }

}