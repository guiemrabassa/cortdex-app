use api::error::CortdexDbError;

pub mod connection;


pub mod api;


pub mod internal;


pub(crate) type Result<T> = core::result::Result<T, CortdexDbError>;