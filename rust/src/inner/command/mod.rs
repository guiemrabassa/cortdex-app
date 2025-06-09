
use std::fmt::Debug;


use cortdex_types::api::{note::{NoteCommand, NoteQuery}, prelude::AttributeCommand};
use enum_dispatch::enum_dispatch;
use flutter_rust_bridge::frb;
use into_request::IntoRequest;
use serde::{Deserialize, Serialize};

use crate::{api::{error::CortdexError}, inner::core::CortdexCore};


pub mod attribute;
pub mod note;

#[derive(Serialize, Deserialize, Debug)]
#[frb(opaque)]
pub struct ConcreteCortdexCommand(pub crate::inner::command::ConcreteInnerCortdexCommand);

impl ConcreteCortdexCommand {

    pub fn new(cmd: crate::inner::command::ConcreteInnerCortdexCommand) -> Self {
        Self(cmd)
    }

}


#[derive(Debug, Serialize, Deserialize)]
pub struct DynamicCmd(pub Box<dyn CortdexCommand>);


#[derive(Serialize, Deserialize, Debug)]
#[enum_dispatch]
pub enum ConcreteInnerCortdexCommand {
    Attribute(AttributeCommand),
    Note(NoteCommand),
    NoteQuery(NoteQuery),
    Dynamic(DynamicCmd)
}



#[typetag::serde]
#[async_trait::async_trait]
impl CortdexCommand for DynamicCmd {

    async fn run(&self, core: &CortdexCore) -> Result<Option<String>, CortdexError> {
        self.0.run(core).await
    }

}

#[typetag::serde(tag = "cortdex_command")]
#[async_trait::async_trait]
#[enum_dispatch(ConcreteInnerCortdexCommand)]
pub trait CortdexCommand: Send + Debug + Sync {

    async fn run(&self, core: &CortdexCore) -> Result<Option<String>, CortdexError>;

}

impl IntoRequest for ConcreteInnerCortdexCommand {

    const ENDPOINT: &'static str = "command";

    fn get_method(&self) -> reqwest::Method {
        reqwest::Method::POST
    }
}