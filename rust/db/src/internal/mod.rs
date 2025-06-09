use anyhow::Context;

use crate::{api::UserSettings, connection::DbConnection};


pub mod note;
pub mod attribute;

impl DbConnection {

    pub async fn update_user_settings(&self, new_settings: UserSettings) -> anyhow::Result<UserSettings> {
        self.db.insert::<Option<UserSettings>>(("user_settings", "user_settings"))
        .content(new_settings)
        .await?
        .context("Failed to update user settings")
    }

    pub async fn get_user_settings(&self) -> anyhow::Result<UserSettings> {
        let settings = self.db.select::<Option<UserSettings>>(("user_settings", "user_settings"))
        .await?;

        if settings.is_none() {
            self.update_user_settings(UserSettings {
                home_page: None
            }).await
        } else {
            settings.context("Failed to get user settings")
        }
    }

}