use anyhow::{Context};
use cortdex_types::{api::attribute::{
    Attribute, AttributeValue, AttributeWithValue
}, utils::error::ErrorContext, DbUtils};
use serde::{Deserialize, Serialize};
use surrealdb::{opt::PatchOp, RecordId};
use uuid::Uuid;

use crate::{connection::DbConnection};


use crate::Result;


#[derive(Serialize, Deserialize)]
struct HasAttribute {
    #[serde(rename = "in")]
    note: RecordId,
    #[serde(rename = "out")]
    attribute: RecordId,
    value: AttributeValue,
}

impl DbConnection {

    /// Adds a new attribute to a given note, this assumes that the attribute and note both exist already
    pub async fn add_attribute_to_note(
        &self,
        note_id: Uuid,
        attribute: String,
        value: AttributeValue,
    ) -> Result<()> {
        self.db
            .insert::<Vec<HasAttribute>>("has_attribute")
            .relation(HasAttribute {
                note: RecordId::from_table_key("note", note_id),
                attribute: RecordId::from_table_key(Attribute::TABLE, attribute),
                value,
            })
            .await
            .ignore_context("insert new attribute")
    }

    pub async fn update_attribute_value(
        &self,
        note_id: Uuid,
        attribute: String,
        value: AttributeValue,
    ) -> Result<()> {
        self.db.query(format!(
            r#"
            UPDATE has_attribute SET value = $value WHERE record::id(in.id) == u'{note_id}' AND out.name == $name
        "#
        ))
        .bind(("value", value.inner_as_json().1))
        //.bind(("id", note_id))
        .bind(("name", attribute))
        .await?
        .take::<Option<HasAttribute>>(0)
        .transpose()
        .context("Failed to take attribute")??
        .value
        .eq(&value).then(|| ())
        .map_context("Failed to update attribute")
    }

    pub async fn remove_attribute_from_note(
        &self,
        note_id: Uuid,
        attribute_name: String,
    ) -> Result<()> {
        self.db
            .query(
                r#"
        DELETE has_attribute WHERE in.id == $note_id AND out.name == $attribute_name;
        "#,
            )
            .bind(("attribute_name", attribute_name))
            .bind(("note_id", RecordId::from_table_key("note", note_id)))
            .await?;

        Ok(())
    }

    pub async fn create_attribute(&self, attribute: Attribute) -> Result<()> {
        self.db
            .insert::<Option<Attribute>>((Attribute::TABLE, attribute.name.clone()))
            .content(attribute)
            .await
            .ignore_context("Failed to create attribute")
    }

    pub async fn delete_attribute(&self, attribute_name: String) -> Result<()> {
        self.db
            .query(r#"DELETE attribute WHERE out.name == $attribute_name;"#)
            .bind(("attribute_name", attribute_name))
            .await
            .ignore_context("Failed to delete attribute")
    }

    /*

    https://surrealdb.com/docs/surrealql/statements/define/analyzer
    This example creates an analyzer specifically designed for auto-completion tasks.

    -- Creates an analyzer suitable for auto-completion.
    DEFINE ANALYZER autocomplete FILTERS lowercase,edgengram(2,10);

    */

    pub async fn get_all_attributes(&self) -> Result<Vec<Attribute>> {
        self.db
            .select::<Vec<Attribute>>(Attribute::TABLE)
            .await
            .map_context("Failed to create attribute")
    }

    pub async fn get_all_attributes_from_note(
        &self,
        note_id: Uuid,
    ) -> Result<Vec<AttributeWithValue>> {
        self.db
            .query(format!(
                r#"
            LET $attributes = SELECT VALUE ->has_attribute FROM note:u'{note_id}';
            SELECT 
                record::id(in.id) AS note_id,
                record::id(out) AS name,
                out.kind AS kind,
                * 
            FROM $attributes[0];
        "#
            ))
            .await?
            .take::<Vec<AttributeWithValue>>(1)
            .map_context("Failed to get all attributes from note")
    }

    pub async fn get_attribute_from_note(
        &self,
        note_id: Uuid,
        name: String,
    ) -> Result<Vec<AttributeWithValue>> {
        // TODO: Check
        self.db
            .query(format!(
                r#"
            LET $attributes = SELECT VALUE ->has_attribute FROM note:u'{note_id}';

            SELECT
                in.id AS note_id,
                record::tb(id) AS name,
                *
            FROM $attributes[0] WHERE name = '{name}';
        "#
            ))
            .await?
            .take::<Vec<AttributeWithValue>>(1)
            .map_context("Failed to get attribute from note")
    }

    pub async fn get_attribute(&self, name: String) -> Result<Attribute> {
        self.db
            .select::<Option<Attribute>>((Attribute::TABLE, name))
            .await?
            .map_context("Failed to find attribute")
    }

    pub async fn get_all_selectable_from_attribute(
        &self,
        attribute_name: String,
    ) -> Result<Vec<String>> {
        self.db
            .query(format!(
                r#"
            (SELECT selectable FROM attribute:{attribute_name}).selectable;
        "#
            ))
            .await?
            .take::<Option<Vec<String>>>(0)?
            .map_context("Failed to find selectable")
    }

    pub async fn add_selectable_to_attribute(
        &self,
        attribute_name: String,
        new_selectable: String,
    ) -> Result<Attribute> {
        self.db
            .update::<Option<Attribute>>((Attribute::TABLE, attribute_name))
            .patch(PatchOp::add("selectable", new_selectable))
            .await?
            .map_context("Failed to add selectable to attribute")
    }

    pub async fn search_attributes(
        &self,
        name: String,
        amount: usize,
        desc: bool,
    ) -> Result<Vec<Attribute>> {
        let order = if desc { "DESC" } else { "ASC" };
        self.db
            .query(format!(
                "
            SELECT * FROM attribute 
            WHERE (name @@ $query OR string::contains(name, $query)) 
            ORDER BY score {order} 
            LIMIT $amount;
        "
            ))
            .bind(("query", name))
            .bind(("amount", amount))
            .await?
            .take::<Vec<Attribute>>(0)
            .map_context("Failed to find attributes")
    }
}

#[cfg(test)]
mod tests {
    use std::collections::HashSet;

    use cortdex_types::api::prelude::AttributeKind;

    use crate::connection;

    use super::*;

    #[tokio::test]
    async fn test_all_note_and_attribute_operations() {
        let db_conn = connection::test_utils::remote_db().await;

        let initial_note = db_conn.create_empty_note().await.unwrap();
        let note_id = initial_note.id;

        let attr_name_description = String::from("Description");
        let attr_name_status = String::from("Status");
        let attr_name_priority = String::from("Priority");
        let attr_name_urgent = String::from("IsUrgent");

        let description_attribute = Attribute {
            name: attr_name_description.clone(),
            kind: AttributeKind::Text,
            options: None,
        };

        let _ = db_conn
            .create_attribute(description_attribute)
            .await
            .unwrap();

        let status_attribute = Attribute {
            name: attr_name_status.clone(),
            kind: AttributeKind::Select,
            options: Some(HashSet::new()),
        };

        let _ = db_conn.create_attribute(status_attribute).await.unwrap();

        let priority_attribute = Attribute {
            name: attr_name_priority.clone(),
            kind: AttributeKind::Number,
            options: None,
        };

        let _ = db_conn.create_attribute(priority_attribute).await.unwrap();

        let urgent_attribute = Attribute {
            name: attr_name_urgent.clone(),
            kind: AttributeKind::Checkbox,
            options: None,
        };

        let _ = db_conn.create_attribute(urgent_attribute).await.unwrap();

        let _ = db_conn
            .add_selectable_to_attribute(attr_name_status.clone(), String::from("Pending"))
            .await
            .unwrap();

        let _ = db_conn
            .add_selectable_to_attribute(attr_name_status.clone(), String::from("In Progress"))
            .await
            .unwrap();

        let _ = db_conn
            .add_selectable_to_attribute(attr_name_status.clone(), String::from("Completed"))
            .await
            .unwrap();

        let _ = db_conn
            .add_attribute_to_note(
                note_id,
                attr_name_description.clone(),
                AttributeValue::Text(String::from("Initial detailed description.")),
            )
            .await
            .unwrap();
        let _ = db_conn
            .add_attribute_to_note(
                note_id,
                attr_name_status.clone(),
                AttributeValue::Select(String::from("Pending")),
            )
            .await
            .unwrap();
        let _ = db_conn
            .add_attribute_to_note(
                note_id,
                attr_name_priority.clone(),
                AttributeValue::Number(1.0),
            )
            .await
            .unwrap();
        let _ = db_conn
            .add_attribute_to_note(
                note_id,
                attr_name_urgent.clone(),
                AttributeValue::Checkbox(false),
            )
            .await
            .unwrap();

        let _ = db_conn
            .update_attribute_value(
                note_id,
                attr_name_description.clone(),
                AttributeValue::Text(String::from("Updated detailed description.")),
            )
            .await
            .unwrap();
        
        assert!(db_conn
            .update_attribute_value(
                note_id,
                attr_name_status.clone(),
                AttributeValue::Select(String::from("In Progress")),
            )
            .await
            .is_err());

        let _ = db_conn
            .update_attribute_value(
                note_id,
                attr_name_priority.clone(),
                AttributeValue::Number(2.0),
            )
            .await
            .unwrap();
        let _ = db_conn
            .update_attribute_value(
                note_id,
                attr_name_urgent.clone(),
                AttributeValue::Checkbox(true),
            )
            .await
            .unwrap();

        let _ = db_conn
            .get_attribute_from_note(note_id, attr_name_description.clone())
            .await
            .unwrap();

        let _ = db_conn.get_all_attributes_from_note(note_id).await.unwrap();

        let _ = db_conn
            .get_attribute(attr_name_status.clone())
            .await
            .unwrap();
        let _ = db_conn.get_all_attributes().await.unwrap();
        let _ = db_conn
            .get_all_selectable_from_attribute(attr_name_status.clone())
            .await
            .unwrap();

        let _ = db_conn
            .search_attributes(String::from("Desc"), 5, false)
            .await
            .unwrap();

        let _ = db_conn
            .remove_attribute_from_note(note_id, attr_name_description.clone())
            .await
            .unwrap();
        let _ = db_conn
            .remove_attribute_from_note(note_id, attr_name_status.clone())
            .await
            .unwrap();

        let _ = db_conn
            .delete_attribute(attr_name_description.clone())
            .await
            .unwrap();
        let _ = db_conn
            .delete_attribute(attr_name_status.clone())
            .await
            .unwrap();
        let _ = db_conn
            .delete_attribute(attr_name_priority.clone())
            .await
            .unwrap();
        let _ = db_conn
            .delete_attribute(attr_name_urgent.clone())
            .await
            .unwrap();

        let _ = db_conn.delete_note(note_id).await.unwrap();
    }
}
