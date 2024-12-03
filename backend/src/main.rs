use axum::{
    extract::DefaultBodyLimit,
    routing::{get, post},
    Router,
};
use recordiary::{
    handlers::{
        calendar::get_calendar,
        deco::{create_deco, get_available_decos, get_deco},
        diary::{create_diary, get_diary},
        health::healthcheck,
        room::{create_user_deco, get_room, update_user_deco},
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
        .route("/diary", post(create_diary).get(get_diary))
        .route("/deco", get(get_deco).post(create_deco))
        .route("/deco/available", get(get_available_decos))
        .route(
            "/room",
            get(get_room).post(create_user_deco).put(update_user_deco),
        )
        .with_state(AppState::default().await)
        .layer(DefaultBodyLimit::max(20 * 1024 * 1024 /* 20mb */)); // about 1 minute per mb

    // run our app with hyper, listening globally on port 3000
    let listener = tokio::net::TcpListener::bind(format!("0.0.0.0:{}", env!("PORT")))
        .await
        .unwrap();
    tracing::debug!("Listening on: {}", listener.local_addr().unwrap());
    axum::serve(listener, app).await.unwrap();
}
