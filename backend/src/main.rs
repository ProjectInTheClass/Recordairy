use axum::{routing::get, Router};
use recordiary::{
    db::conn::initialize_conn_pool,
    handlers::{calendar::get_calendar, health::healthcheck},
    storage::client::SupabaseClient,
};

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/", get(healthcheck))
        .route("/calendar", get(get_calendar))
        .with_state(initialize_conn_pool().await)
        .with_state(SupabaseClient::new(
            std::env::var("SUPABASE_URL").unwrap(),
            std::env::var("SUPABASE_KEY").unwrap(),
        ));

    // run our app with hyper, listening globally on port 3000
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
