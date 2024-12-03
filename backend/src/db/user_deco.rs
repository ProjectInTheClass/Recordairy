use serde::{Deserialize, Serialize};
use serde_json::json;
use sqlx::{
    types::{BigDecimal, Json},
    FromRow, PgConnection,
};
use time::{Date, OffsetDateTime};
use uuid::Uuid;

use crate::utils::coordinates::Coordinates;

#[derive(Deserialize, Serialize, Clone, FromRow, Debug)]
pub struct UserDeco {
    user_id: Uuid,
    // deco part
    deco_id: i64,
    name: String,
    asset_link: String,
    category: Option<String>,
    display_name: Option<String>,
    // diary part
    diary_id: i64,
    #[serde(with = "time::serde::rfc3339")]
    pub created_at: OffsetDateTime,
    local_date: Date,
    audio_link: Option<String>,
    summary: Option<String>,
    is_private: bool,
    is_placed: bool,
    coordinates: Option<Json<Coordinates>>,
}

pub async fn get_user_deco_of_month(
    tx: &mut PgConnection,
    user_id: Uuid,
    year: i32,
    month: u32,
) -> sqlx::Result<Vec<UserDeco>> {
    sqlx::query_as!(
        UserDeco,
        r#"
        SELECT
            diary.user_id as user_id,
            deco.id as deco_id,
            deco.name as name,
            deco.asset_link as asset_link,
            deco.category as category,
            deco.display_name as display_name,
            diary.id as diary_id,
            diary.created_at as created_at,
            diary.local_date as local_date,
            diary.audio_link as audio_link,
            diary.summary as summary,
            diary.is_private as is_private,
            user_deco.is_placed as is_placed,
            user_deco.coordinates as "coordinates: Json<Coordinates>"
        FROM deco 
        JOIN user_deco ON user_deco.user_id = $1 AND user_deco.deco_id = deco.id
        JOIN diary ON diary.id = user_deco.diary_id
        WHERE diary.user_id = $1 AND EXTRACT(YEAR FROM local_date) = $2 AND EXTRACT(MONTH FROM local_date) = $3
        "#,
        user_id,
        BigDecimal::from(year),
        month as i32,
    )
    .fetch_all(tx)
    .await
}

pub async fn create_user_deco(
    tx: &mut PgConnection,
    user_id: Uuid,
    diary_id: i64,
    deco_id: i64,
) -> sqlx::Result<()> {
    sqlx::query!(
        "
        INSERT INTO user_deco (user_id, diary_id, deco_id)
        VALUES ($1, $2, $3)
        ",
        user_id,
        diary_id,
        deco_id,
    )
    .execute(tx)
    .await?;
    Ok(())
}

pub async fn update_user_deco(
    tx: &mut PgConnection,
    user_id: Uuid,
    diary_id: i64,
    deco_id: i64,
    is_placed: bool,
    coordinates: Option<Coordinates>,
) -> sqlx::Result<()> {
    let coordinates: Option<serde_json::Value> = coordinates.map(|c| json!(c));

    sqlx::query!(
        "
        UPDATE user_deco
        SET is_placed = $1, coordinates = $2
        WHERE user_id = $3 AND diary_id = $4 AND deco_id = $5
        ",
        is_placed,
        coordinates,
        user_id,
        diary_id,
        deco_id,
    )
    .execute(tx)
    .await?;
    Ok(())
}
