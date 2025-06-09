
use cortdex_types::api::note::NoteEditingCommand;





use crate::inner::{stream::CortdexStream, websockets::CustomWsSplitStream};





/* #[delegatable_trait]
pub trait NoteEditingService {

    async fn apply_content_delta(&mut self, delta: String, markdown: String) -> Result<(), CortdexError>;

    async fn get_change_stream(&mut self, stream: StreamSink<NoteEditingCommand>) -> Result<(), CortdexError>;

    async fn disconnect(&mut self) -> Result<(), CortdexError>;

} */

pub enum NoteEditor {
    Remote(CustomWsSplitStream),
    Local(CortdexStream<NoteEditingCommand>)
    // Local
}
