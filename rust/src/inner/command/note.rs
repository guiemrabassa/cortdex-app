use cortdex_ml::embedder::Embedder;
use cortdex_types::{
    api::note::{NoteCommand, NoteQuery},
    SerializedResult,
};
use futures::{FutureExt, TryFutureExt};
use log::debug;

use crate::api::IntoConcreteCortexCommand;

use super::{ConcreteCortdexCommand, CortdexCommand};

#[typetag::serde]
#[async_trait::async_trait]
impl CortdexCommand for NoteCommand {
    async fn run(
        &self,
        core: &crate::inner::core::CortdexCore,
    ) -> Result<Option<String>, crate::api::error::CortdexError> {
        return match self.clone() {
            NoteCommand::ChangeTitle { id, new_title } => {
                core.db_pool.update_note_title(id, new_title).await?;

                let diffs = core.db_pool.get_changed_embeddings().await?;
                let new_embeddings = core.model_manager.get_model()?.calc_embeddings(diffs);

                core.db_pool
                    .set_changed_embeddings(new_embeddings)
                    .await
                    .serialized()
            }
            NoteCommand::ChangeContent { id, new_content } => {
                core.db_pool.update_note_content(id, new_content).await?;

                let diffs = core.db_pool.get_changed_embeddings().await?;
                let new_embeddings = core.model_manager.get_model()?.calc_embeddings(diffs);

                core.db_pool
                    .set_changed_embeddings(new_embeddings)
                    .await
                    .serialized()
            }
            NoteCommand::Create => core.db_pool.create_empty_note().await.serialized(),
            NoteCommand::Get { id } => core.db_pool.get_note_by_id(id).await.serialized(),
            NoteCommand::Delete { id } => core.db_pool.delete_note(id).await.serialized(),
        }
        .map_err(Into::into);
    }
}

impl IntoConcreteCortexCommand for NoteCommand {
    fn into_ccd(self) -> ConcreteCortdexCommand {
        ConcreteCortdexCommand::new(super::ConcreteInnerCortdexCommand::Note(self))
    }
}

#[typetag::serde]
#[async_trait::async_trait]
impl CortdexCommand for NoteQuery {
    async fn run(
        &self,
        core: &crate::inner::core::CortdexCore,
    ) -> Result<Option<String>, crate::api::error::CortdexError> {
        match self.clone() {
            NoteQuery::Basic { amount, text } => {
                debug!("Searching {amount} notes with: {text}.");

                let embed = core
                    .model_manager
                    .get_model()?
                    .get_embeddings(text.clone())?;
                
                let notes = core.db_pool.search_notes(text, amount, embed).await?;

                debug!("Found {notes:?}.");

                serde_json::to_string(&notes)
                    .map(Some)
                    .map_err(Into::into)
            },
            NoteQuery::Full { amount, text } => {
                debug!("Searching {amount} notes with: {text}.");

                let embed = core
                    .model_manager
                    .get_model()?
                    .get_embeddings(text.clone())?;
                
                let notes = core.db_pool.search_notes_with_attributes(text, amount, embed).await?;

                debug!("Found {notes:?}.");

                serde_json::to_string(&notes)
                    .map(Some)
                    .map_err(Into::into)
            }
        }
    }
}

impl IntoConcreteCortexCommand for NoteQuery {
    fn into_ccd(self) -> ConcreteCortdexCommand {
        ConcreteCortdexCommand::new(super::ConcreteInnerCortdexCommand::NoteQuery(self))
    }
}

#[cfg(test)]
mod tests {
    use cortdex_db::connection;
    use cortdex_ml::{api::manager::ModelManagerConfig, embedder::Embedder, manager::ModelManager};

    #[tokio::test]
    async fn calc_embeddings() {
        let db_conn = connection::test_utils::remote_db().await;

        let note = db_conn.create_empty_note().await.unwrap();
        let id = note.id;

        let _ = db_conn
            .update_note(
                id,
                String::from("Test note"),
                String::from("Content for Test note"),
            )
            .await
            .unwrap();

        let embeddings = db_conn.get_changed_embeddings().await.unwrap();

        let path = cortdex_types::test_utils::get_test_path()
            .to_str()
            .unwrap()
            .to_string();

        let mut manager = ModelManager::new(ModelManagerConfig::new_basic(path));

        let _ = manager.setup().await.unwrap();

        let model = manager.get_model().unwrap();

        let new_embeddings = model.value().calc_embeddings(embeddings);

        db_conn
            .set_changed_embeddings(new_embeddings)
            .await
            .unwrap();

        let _ = db_conn.delete_note(id).await.unwrap();
    }
}
