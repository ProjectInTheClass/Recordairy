use serde::{Deserialize, Serialize};
use sqlx::{types::Uuid, FromRow, PgConnection, PgPool, Row};
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
    audio_link: Option<String>,
    summary: Option<String>,
    is_private: bool,
}

impl DiaryParams {
    pub fn new(
        user_id: Uuid,
        audio_link: Option<String>,
        summary: Option<String>,
        is_private: bool,
    ) -> Self {
        Self {
            user_id,
            audio_link,
            summary,
            is_private,
        }
    }
}

pub async fn get_diaries(
    tx: &PgPool,
    user_id: Uuid,
    diary_ids: Vec<i64>,
) -> anyhow::Result<Vec<Diary>> {
    let resp: Vec<Diary> = sqlx::query_as("SELECT * FROM diary WHERE user_id = $1 AND id IN ($2)")
        .bind(user_id)
        .bind(&diary_ids)
        .fetch_all(tx)
        .await?;
    Ok(resp)
}

pub async fn get_diaries_of_month(
    pool: &PgPool,
    year: u32,
    month: u32,
    user_id: Uuid,
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
    .bind(user_id)
    .fetch_all(pool)
    .await?;
    Ok(resp)
}

pub async fn insert_diary(tx: &mut PgConnection, diary: DiaryParams) -> anyhow::Result<i64> {
    let row = sqlx::query(
        "
    INSERT INTO diary (user_id, audio_link, summary, is_private) VALUES ($1,$2,$3,$4) RETURNING id",
    )
    .bind(diary.user_id)
    .bind(diary.audio_link)
    .bind(diary.summary)
    .bind(diary.is_private)
    .fetch_one(tx)
    .await?;
    Ok(row.try_get::<i64, _>("id")?)
}
