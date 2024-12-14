use axum::extract::FromRef;
use db::conn::initialize_conn_pool;
use openai::client::OpenAIClient;
use storage::client::SupabaseClient;

pub mod db;
pub mod handlers;
pub mod openai;
pub mod storage;
pub mod utils;

#[derive(Clone)]
pub struct AppState {
    pool: sqlx::PgPool,
    storage_client: SupabaseClient,
    openai_client: OpenAIClient,
}

impl AppState {
    pub async fn default() -> Self {
        Self {
            pool: initialize_conn_pool().await,
            storage_client: SupabaseClient::new(
                std::env::var("SUPABASE_URL").unwrap(),
                std::env::var("SUPABASE_KEY").unwrap(),
                std::env::var("SUPABASE_AUDIO_BUCKET").unwrap(),
                std::env::var("SUPABASE_MODEL_BUCKET").unwrap(),
            ),
            openai_client: OpenAIClient::new(),
        }
    }
}

impl FromRef<AppState> for sqlx::PgPool {
    fn from_ref(state: &AppState) -> sqlx::PgPool {
        state.pool.clone()
    }
}

impl FromRef<AppState> for SupabaseClient {
    fn from_ref(state: &AppState) -> SupabaseClient {
        state.storage_client.clone()
    }
}

impl FromRef<AppState> for OpenAIClient {
    fn from_ref(state: &AppState) -> OpenAIClient {
        state.openai_client.clone()
    }
}
