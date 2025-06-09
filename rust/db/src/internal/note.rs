
use anyhow::Context;
use cortdex_types::{api::note::{Note, NoteWithId}, embedding::{Embedding, EmbeddingDiff, EmbeddingOfNote}, utils::error::ErrorContext};

use quill_delta_rs::delta::Delta;
use surrealdb::opt::PatchOp;
use uuid::Uuid;

use crate::connection::DbConnection;

use crate::Result;

// Finds the embeddings that have been changed
// and returns their id and the note content and id
const FIND_CHANGED_EMBEDDINGS: &str = r#"
LET $changed_embeddings = SELECT * FROM embedding WHERE changed IS true;

SELECT
    record::id(id) as id,
    array::first(<-embedded<-note.content) as content,
    array::first(<-embedded<-note.title) as title
FROM $changed_embeddings WHERE array::first(<-embedded<-note) != NONE;

"#;

pub fn format_delta(content: String) -> Result<Delta> {
    const DELTA_START: &str = r#"{"ops":"#;
    const DELTA_END: &str = r#"}"#;

    let formatted = &format!("{DELTA_START}{content}{DELTA_END}");

    serde_json::from_str(formatted).map_context("Failed to parse delta")
}

impl DbConnection {
    pub async fn create_empty_note(&self) -> Result<Note> {
        let content: NoteWithId = Note::default().into();
        self.db
            .create::<Option<NoteWithId>>("note")
            .content(content)
            .await
            .context("create note")?
            .context("create note")
            .map(TryInto::try_into)
            .context("Failed to transform")?
            .map_err(Into::into)
    }

    pub async fn get_changed_embeddings(&self) -> Result<Vec<EmbeddingDiff>> {
        self.db
            .query(FIND_CHANGED_EMBEDDINGS)
            .await
            .context("find changed embeddings")?
            .take::<Vec<EmbeddingDiff>>(1)
            .map_context("Failed to find changed embeddings")
    }

    pub async fn set_changed_embeddings(&self, embeds: Vec<EmbeddingOfNote>) -> Result<()> {
        for diff in embeds {
            self.db
                .update::<Option<Embedding>>(("embedding", diff.id))
                .patch(PatchOp::replace("/changed", false))
                .patch(PatchOp::replace("/vectors", diff.vectors))
                .await
                .context("Failed to change embeddings")?;
        }

        Ok(())
    }

    pub async fn get_note_by_id(&self, id: Uuid) -> Result<Note> {
        self.db
            .select::<Option<NoteWithId>>(("note", id))
            .await
            .context("Failed to find note")?
            .map(TryInto::try_into)
            .transpose()?
            .map_context("Failed to transform note")
    }


    pub async fn search_notes(
        &self,
        query: String,
        amount: usize,
        embed: Vec<f32>,
    ) -> Result<Vec<Note>> {
        // TODO: Search by all attribute kinds
        self.db.query(format!(r#"
            LET $embedded_search = (
                SELECT array::first(<-embedded<-note.*) AS note
                FROM embedding 
                WHERE vectors <|{amount}|>  $query_embeddings
            ).note;

            LET $text_search = SELECT * FROM note
            WHERE (content @@ $query OR string::contains(content, $query) OR title @@ $query OR string::contains(title, $query))
            ORDER BY score DESC
            LIMIT {amount};

            array::group([$embedded_search, $text_search]);
        "#))
        .bind(("query", query.clone()))
        .bind(("query_embeddings", embed))
        .await
        .context("Failed to find notes")?
        .take::<Vec<NoteWithId>>(2).context("Failed to find notes")?
        .into_iter()
        .map(TryInto::try_into)
        .collect::<anyhow::Result<Vec<Note>>>().map_err(Into::into)
    }

    pub async fn search_notes_with_attributes(
        &self,
        query: String,
        amount: usize,
        embed: Vec<f32>,
    ) -> Result<Vec<Note>> {
        // TODO: Search by all attribute kinds
        self.db.query(format!(r#"
            LET $embedded_search = (
                SELECT array::first(<-embedded<-note.*) AS note
                FROM embedding 
                WHERE vectors <|{amount}|>  $query_embeddings
            ).note;

            LET $text_search = SELECT * FROM note
            WHERE (content @@ $query OR string::contains(content, $query) OR title @@ $query OR string::contains(title, $query))
            ORDER BY score DESC
            LIMIT {amount};

            LET $attr_search = array::distinct((SELECT in.* FROM has_attribute WHERE {{
                LET $kind = fn::attribute::get_kind(out.name);
                fn::attribute::equal::select($kind, $query) OR
                fn::attribute::equal::multi_select($kind, $query) OR
                fn::attribute::equal::checkbox($kind, $query) OR
                fn::attribute::equal::text($kind, $query)
            }}).in);

            array::group([$embedded_search, $text_search, $attr_search]);
        "#))
        .bind(("query", query.clone()))
        .bind(("query_embeddings", embed))
        .await
        .context("find notes")?
        .take::<Vec<NoteWithId>>(3)
        .map_err(anyhow::Error::msg)?
        .into_iter()
        .map(TryInto::try_into)
        .collect::<anyhow::Result<Vec<Note>>>().map_err(Into::into)
    }

    pub async fn update_note(&self, id: Uuid, title: String, content: String) -> Result<()> {
        self.db
            .update::<Option<NoteWithId>>(("note", id))
            .patch(PatchOp::replace("/title", title))
            .patch(PatchOp::replace("/content", content))
            .await
            .ignore_context("Failed to update content")
    }

    pub async fn update_note_title(&self, id: Uuid, title: String) -> Result<()> {
        self.db
            .update::<Option<NoteWithId>>(("note", id))
            .patch(PatchOp::replace("/title", title))
            .await
            .ignore_context("Failed to update note title")
    }

    pub async fn update_note_content(&self, id: Uuid, content: String) -> Result<()> {
        self.db
            .update::<Option<NoteWithId>>(("note", id))
            .patch(PatchOp::replace("/content", content))
            .await
            .ignore_context("Failed to update note content")
    }

    pub async fn delete_note(&self, id: Uuid) -> Result<()> {
        self.db
            .delete::<Option<NoteWithId>>(("note", id))
            .await
            .ignore_context("remove note")
    }
}



#[cfg(test)]
mod tests {
    use crate::connection;

    #[tokio::test]
    async fn test_all_note_queries() {
        let db_conn = connection::test_utils::remote_db().await;

        let note = db_conn.create_empty_note().await.unwrap();
        let id = note.id;
        let _ = db_conn.get_note_by_id(id).await.unwrap();
        let _ = db_conn
            .update_note(
                id,
                String::from("Test note"),
                String::from("Content for Test note"),
            )
            .await
            .unwrap();
        let _ = db_conn
            .update_note_title(id, String::from("Test note 2"))
            .await
            .unwrap();
        let _ = db_conn
            .update_note_content(id, String::from("Content for Test note 2"))
            .await
            .unwrap();

        let _ = db_conn.delete_note(id).await.unwrap();
    }
}
