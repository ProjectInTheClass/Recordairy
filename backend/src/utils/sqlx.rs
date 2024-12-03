use sqlx::{PgPool, Postgres, Transaction};

pub async fn get_pg_tx(pool: PgPool) -> axum::response::Result<Transaction<'static, Postgres>> {
    match pool.begin().await {
        Ok(tx) => Ok(tx),
        Err(e) => Err(e.to_string().into()),
    }
}
