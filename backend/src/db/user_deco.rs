use serde::{Deserialize, Serialize};
use sqlx::{types::BigDecimal, FromRow, PgConnection};
use time::{Date, OffsetDateTime};
use uuid::Uuid;

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
}

pub async fn get_user_deco_of_month(
    tx: &mut PgConnection,
    user_id: Uuid,
    year: i32,
    month: u32,
) -> sqlx::Result<Vec<UserDeco>> {
    sqlx::query_as!(
        UserDeco,
        "
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
            diary.is_private as is_private
        FROM deco 
        JOIN user_deco ON user_deco.user_id = $1 AND user_deco.deco_id = deco.id
        JOIN diary ON diary.id = user_deco.diary_id
        WHERE diary.user_id = $1 AND EXTRACT(YEAR FROM local_date) = $2 AND EXTRACT(MONTH FROM local_date) = $3
        ",
        user_id,
        BigDecimal::from(year),
        month as i32,
    )
    .fetch_all(tx)
    .await
}
