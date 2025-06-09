use std::sync::{Arc, Mutex};

use anyhow::Context;


pub mod error;
pub mod manager;
mod model;

pub mod embedder;

pub mod api;

#[derive(Clone)]
pub struct SafeOptional<T> {
    data: Arc<Mutex<Option<T>>>
}

impl<T: Clone> SafeOptional<T> {
    pub fn new() -> Self {
        Self {
            data: Arc::new(Mutex::new(None))
        }
    }

    /// Will try to replace, it will fail if it's already borrowed
    pub fn replace(&self, new: T) -> anyhow::Result<()> {
        if let Ok(mut inner) = self.data.try_lock() {
            inner.replace(new);
        }
        Ok(())
    }

    pub fn lock_and_get(&self) -> anyhow::Result<T> {
        if let Ok(d) = self.data.try_lock() {
            let f= d.clone().context("Failed to get the inner object");
            return f;
        }

        Err(anyhow::Error::msg("message"))
    }
}