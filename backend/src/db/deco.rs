use serde::{Deserialize, Serialize};
use sqlx::{FromRow, PgConnection};
use time::OffsetDateTime;

#[derive(Deserialize, Serialize, Clone, FromRow, Debug)]
pub struct Deco {
    id: i64,
    #[serde(with = "time::serde::rfc3339")]
    pub created_at: OffsetDateTime,
    #[serde(with = "time::serde::rfc3339")]
    pub updated_at: OffsetDateTime,
    name: String,
    asset_link: String,
    category: Option<String>,
    is_valid: bool,
    display_name: Option<String>,
}

pub async fn get_deco(tx: &mut PgConnection, deco_id: i64) -> anyhow::Result<Deco> {
    let deco = sqlx::query_as!(Deco, "SELECT * FROM deco WHERE id = $1", deco_id)
        .fetch_one(tx)
        .await?;

    Ok(deco)
}

pub struct CreateDecoParams {
    pub name: String,
    pub display_name: Option<String>,
    pub category: String,
    pub asset_link: Option<String>,
    pub is_valid: bool,
}

pub async fn create_deco(tx: &mut PgConnection, params: CreateDecoParams) -> anyhow::Result<Deco> {
    let deco = sqlx::query_as!(
        Deco,
        "INSERT INTO deco (name, display_name, category, asset_link, is_valid) VALUES ($1, $2, $3, $4, $5) RETURNING *",
        params.name,
        params.display_name,
        params.category,
        params.asset_link,
        params.is_valid
    )
    .fetch_one(tx)
    .await?;
    Ok(deco)
}

pub async fn get_available_decos(tx: &mut PgConnection) -> anyhow::Result<Vec<Deco>> {
    let decos = sqlx::query_as!(Deco, "SELECT * FROM deco WHERE is_valid = true")
        .fetch_all(tx)
        .await?;

    Ok(decos)
}
