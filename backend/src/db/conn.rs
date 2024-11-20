use std::time::Duration;

use sqlx::{
    postgres::{PgConnectOptions, PgPoolOptions},
    Pool, Postgres,
};

pub async fn initialize_conn_pool() -> Pool<Postgres> {
    let db_host = std::env::var("DB_HOST").expect("DB_HOST must be set");
    let db_user = std::env::var("DB_USER").expect("DB_USER must be set");
    let db_password = std::env::var("DB_PASSWORD").expect("DB_PASSWORD must be set");
    let db_name = std::env::var("DB_NAME").expect("DB_NAME must be set");
    let db_port = std::env::var("DB_PORT").expect("DB_PORT must be set");

    let db_connection_opts = PgConnectOptions::new()
        .username(&db_user)
        .password(&db_password)
        .database(&db_name)
        .port(db_port.parse::<u16>().unwrap())
        .host(&db_host);

    // setup connection pool
    PgPoolOptions::new()
        .max_connections(5)
        .acquire_timeout(Duration::from_secs(3))
        .connect_with(db_connection_opts)
        .await
        .expect("can't connect to database")
}
