use axum::{
    extract::DefaultBodyLimit,
    routing::{get, post},
    Router,
};
use recordiary::{
    handlers::{
        calendar::get_calendar,
        diary::{create_diary, get_diaries},
        health::healthcheck,
    },
    AppState,
};
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

#[tokio::main]
async fn main() {
    tracing_subscriber::registry()
        .with(
            tracing_subscriber::EnvFilter::try_from_default_env().unwrap_or_else(|_| {
                format!(
                    "{}=debug,tower_http=debug,axum::rejection=trace",
                    env!("CARGO_CRATE_NAME")
                )
                .into()
            }),
        )
        .with(tracing_subscriber::fmt::layer())
        .init();

    let app = Router::new()
        .route("/", get(healthcheck))
        .route("/calendar", get(get_calendar))
        .route("/diary", post(create_diary).get(get_diaries))
        .with_state(AppState::default().await)
        .layer(DefaultBodyLimit::max(20 * 1024 * 1024 /* 20mb */));

    // run our app with hyper, listening globally on port 3000
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    tracing::debug!("Listening on: {}", listener.local_addr().unwrap());
    axum::serve(listener, app).await.unwrap();
}
