use cortdex_types::api::attribute::AttributeCommand;

use crate::{
    api::IntoConcreteCortexCommand,
    inner::core::CortdexCore,
};

use super::{ConcreteCortdexCommand, CortdexCommand};

#[typetag::serde]
#[async_trait::async_trait]
impl CortdexCommand for AttributeCommand {
    async fn run(
        &self,
        core: &CortdexCore,
    ) -> Result<Option<String>, crate::api::error::CortdexError> {
        let cmd = self.clone();
        let db = &core.db_pool;

        match cmd {
            AttributeCommand::AddToNote {
                note_id,
                attribute_name,
                attribute_value,
            } => {
                db.add_attribute_to_note(note_id, attribute_name, attribute_value).await?;
            },
            AttributeCommand::AddToSelectable {
                attribute_name,
                new_selectable,
            } => {
                db.add_selectable_to_attribute(attribute_name, new_selectable)
                    .await?;
            }
            AttributeCommand::Create { def } => {
                db.create_attribute(def).await?;
            },
            AttributeCommand::Get { name } => {
                return db
                .get_attribute(name)
                .await
                .map(|result| serde_json::to_string(&result).ok())
                .map_err(Into::into);
            },
            AttributeCommand::GetAllFromNote { note_id } => {
                return db
                .get_all_attributes_from_note(note_id)
                .await
                .map(|result| serde_json::to_string(&result).ok())
                .map_err(Into::into);
            },
            AttributeCommand::GetAllFromSelectable { attribute_name } => {
                return db
                .get_all_selectable_from_attribute(attribute_name)
                .await
                .map(|result| serde_json::to_string(&result).ok())
                .map_err(Into::into);
            },
            AttributeCommand::GetFromNote { note_id, name } => {
                return db
                .get_attribute_from_note(note_id, name)
                .await
                .map(|result| serde_json::to_string(&result).ok())
                .map_err(Into::into);
            },
            AttributeCommand::RemoveFromNote { note_id, name } => {
                db.remove_attribute_from_note(note_id, name).await?;
            }
            AttributeCommand::Search {
                amount,
                query,
                desc,
            } => {
                return db
                .search_attributes(query, amount, desc)
                .await
                .map(|result| serde_json::to_string(&result).ok())
                .map_err(Into::into);
            },
            AttributeCommand::UpdateValueOnNote {
                note_id,
                attribute_name,
                attribute_value,
            } => {
                db.update_attribute_value(note_id, attribute_name, attribute_value)
                    .await?;
            }
        };

        Ok(None)
    }
}

impl IntoConcreteCortexCommand for AttributeCommand {
    fn into_ccd(self) -> ConcreteCortdexCommand {
        ConcreteCortdexCommand::new(super::ConcreteInnerCortdexCommand::Attribute(self))
    }
}