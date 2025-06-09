use chrono::NaiveDateTime;

use log::debug;
use log::info;
use serde::Deserialize;
use serde::Serialize;

use surrealdb::engine::any::Any;
use surrealdb::opt::auth::Root;
use surrealdb::sql::Thing;
use surrealdb::Surreal;

use crate::api::DbPath;

#[derive(Debug, Serialize, Deserialize)]
enum FileType {
    Text,
    Image,
    Voice,
}

#[derive(Clone)]
pub struct DbConnection {
    pub db: Surreal<Any>,
    pub remote: bool,
}

impl DbConnection {
    pub async fn new(path: DbPath) -> anyhow::Result<Self> {
        let db = Surreal::<Any>::init();
        let remote;

        debug!("Creating new DbConnection with path: {:?}", path);

        match path {
            DbPath::Local { path } => {
                db.connect(format!("surrealkv://{path}")).await?;
                remote = false;
            }
            DbPath::Remote { address, port } => {
                db.connect(format!("ws://{address}:{port}")).await?;
                remote = true;
            }
        }

        let db = DbConnection { db, remote };

        db.prepare_test().await?;
        db.ready_db().await?;

        Ok(db)
    }

    /// Sets the namespace and database to be test
    pub async fn prepare_test(&self) -> anyhow::Result<()> {
        if self.remote {
            self.db
                .signin(Root {
                    username: "root",
                    password: "root",
                })
                .await?;
        }
        
        info!("Signed as root");

        self.db
            .use_ns("test")
            .use_db("test")
            .await
            .map_err(anyhow::Error::msg)
    }

    pub async fn ready_db(&self) -> anyhow::Result<()> {
        let all = include_str!("../sentences/all.surql");

        self.db.query(all).await?;

        Ok(())
    }
}

pub mod test_utils {
    use crate::api::DbPath;

    use super::DbConnection;

    pub async fn local_db() -> DbConnection {
        let home = std::env::home_dir()
            .expect("No home directory")
            .join("cortdex")
            .to_str()
            .unwrap()
            .to_string();
        DbConnection::new(DbPath::Local { path: home })
            .await
            .expect("Failed to connect")
    }

    pub async fn remote_db() -> DbConnection {
        DbConnection::new(DbPath::Remote {
            address: String::from("localhost"),
            port: 80,
        })
        .await
        .expect("Failed to connect")
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn local_db() { test_utils::local_db().await; }

    #[tokio::test]
    async fn remote_db() {
        test_utils::remote_db().await;
    }

    #[tokio::test]
    async fn remote_ready() {
        let conn = test_utils::remote_db().await;
        conn.prepare_test()
            .await
            .expect("Failed to login as test user");
        conn.ready_db().await.expect("Failed to ready db");
    }
}
