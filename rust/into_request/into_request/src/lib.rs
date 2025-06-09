use reqwest::Method;
use serde::Serialize;


#[cfg(feature = "derive")]
extern crate into_request_derive;


#[cfg(feature = "derive")]
#[cfg_attr(docsrs, doc(cfg(feature = "derive")))]
pub use into_request_derive::IntoRequest;

pub trait IntoRequest: Serialize + std::fmt::Debug {

    const ENDPOINT: &'static str;

    fn get_method(&self) -> Method;

    fn get_endpoint(&self) -> &'static str {
        Self::ENDPOINT
    }

    fn into_body(&self) -> reqwest::Body {
        serde_json::to_string(self).unwrap().into()
    }

}