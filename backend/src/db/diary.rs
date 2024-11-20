use serde::{Deserialize, Serialize};
use sqlx::{types::Uuid, FromRow, PgPool};
use time::{Date, OffsetDateTime};

#[derive(Deserialize, Serialize, FromRow, Debug)]
pub struct Diary {
    id: i64,
    #[serde(with = "time::serde::rfc3339")]
    pub created_at: OffsetDateTime,
    local_date: Date,
    user_id: Uuid,
    audio_link: String,
    summary: String,
    is_private: bool,
}

pub struct DiaryParams {
    user_id: Uuid,
    audio_link: String,
    summary: String,
    is_private: bool,
}

pub async fn get_diaries_of_month(
    pool: &PgPool,
    year: u32,
    month: u32,
    user_id: String,
) -> anyhow::Result<Vec<Diary>> {
    // todo: connect to supabase and get diaries of user
    let resp: Vec<Diary> = sqlx::query_as(
        "SELECT * FROM diary where 
    EXTRACT(YEAR from created_at) = $1 AND
    EXTRACT(MONTH from created_at) = $2 AND
    user_id = $3",
    )
    .bind(year as i32)
    .bind(month as i32)
    .bind(Uuid::parse_str(&user_id)?)
    .fetch_all(pool)
    .await?;
    Ok(resp)
}

pub async fn insert_diary(pool: &PgPool, diary: DiaryParams) -> anyhow::Result<()> {
    sqlx::query(
        "
    INSERT INTO diary (user_id, audio_link, summary, is_private) VALUES ($1,$2,$3,$4)",
    )
    .bind(diary.user_id)
    .bind(diary.audio_link)
    .bind(diary.summary)
    .bind(diary.is_private)
    .execute(pool)
    .await?;
    Ok(())
}