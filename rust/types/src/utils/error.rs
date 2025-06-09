use std::{error::Error, fmt::Display};

use anyhow::Context;




pub trait ErrorContext<T, O> {

    fn ignore_context<C>(self, context: C) -> Result<(), O> where C: Display + Send + Sync + 'static;

    fn map_context<C>(self, context: C) -> Result<T, O> where C: Display + Send + Sync + 'static;

}

impl<T, I: Display + Send + Sync + 'static + Error, O: std::convert::From<anyhow::Error>> ErrorContext<T, O> for Result<T, I> {
    fn ignore_context<C>(self, context: C) -> Result<(), O> where C: Display + Send + Sync + 'static {
        self.map(|_|()).context(context).map_err(Into::into)
    }

    fn map_context<C>(self, context: C) -> Result<T, O> where C: Display + Send + Sync + 'static {
        self.context(context).map_err(Into::into)
    }
}

impl<T, O: std::convert::From<anyhow::Error>> ErrorContext<T, O> for Option<T> {
    fn ignore_context<C>(self, context: C) -> Result<(), O> where C: Display + Send + Sync + 'static {
        self.map(|_|()).context(context).map_err(Into::into)
    }

    fn map_context<C>(self, context: C) -> Result<T, O> where C: Display + Send + Sync + 'static {
        self.context(context).map_err(Into::into)
    }
}