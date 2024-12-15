use serde::{Deserialize, Serialize};
use sqlx::{types::Uuid, FromRow, PgConnection, PgPool, Postgres};
use time::{Date, OffsetDateTime};

#[derive(Deserialize, Serialize, Clone, FromRow, Debug)]
pub struct Diary {
    id: i64,
    #[serde(with = "time::serde::rfc3339")]
    pub created_at: OffsetDateTime,
    local_date: Date,
    user_id: Uuid,
    audio_link: Option<String>,
    summary: Option<String>,
    transcription: Option<String>,
    emotion: Option<String>,
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
    let resp: Vec<Diary> = sqlx::query_as!(
        Diary,
        "SELECT * FROM diary WHERE user_id = $1 AND id = ANY($2)",
        user_id,
        &diary_ids
    )
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
    let resp: Vec<Diary> = sqlx::query_as!(
        Diary,
        "SELECT * FROM diary where 
    EXTRACT(YEAR from created_at) = $1 AND
    EXTRACT(MONTH from created_at) = $2 AND
    user_id = $3",
        year as i32,
        month as i32,
        user_id
    )
    .fetch_all(pool)
    .await?;
    Ok(resp)
}

pub async fn insert_diary(tx: &mut PgConnection, diary: DiaryParams) -> anyhow::Result<i64> {
    let row = sqlx::query!(
        "
    INSERT INTO diary (user_id, audio_link, summary, is_private) VALUES ($1,$2,$3,$4) RETURNING id",
        diary.user_id,
        diary.audio_link,
        diary.summary,
        diary.is_private
    )
    .fetch_one(tx)
    .await?;
    Ok(row.id)
}

pub async fn update_diary(
    tx: &mut PgConnection,
    id: i64,
    audio_link: Option<String>,
    summary: Option<String>,
    transcription: Option<String>,
    emotion: Option<String>,
    is_private: Option<bool>,
) -> anyhow::Result<()> {
    if audio_link.is_none()
        && summary.is_none()
        && transcription.is_none()
        && is_private.is_none()
        && emotion.is_none()
    {
        return Ok(());
    }
    let mut qry_builder: sqlx::QueryBuilder<'_, Postgres> =
        sqlx::query_builder::QueryBuilder::new("UPDATE diary SET ");
    let mut separated = qry_builder.separated(", ");
    let mut first = true;

    if let Some(audio_link) = audio_link {
        if !first {
            separated.push_unseparated(", ");
        }
        separated.push_unseparated("audio_link = ");
        separated.push_bind_unseparated(audio_link);
        first = false;
    }
    if let Some(summary) = summary {
        if !first {
            separated.push_unseparated(", ");
        }
        separated.push_unseparated("summary = ");
        separated.push_bind_unseparated(summary);
        first = false;
    }
    if let Some(transcription) = transcription {
        if !first {
            separated.push_unseparated(", ");
        }
        separated.push_unseparated("transcription = ");
        separated.push_bind_unseparated(transcription);
        first = false;
    }
    if let Some(emotion) = emotion {
        if !first {
            separated.push_unseparated(", ");
        }
        separated.push_unseparated("emotion = ");
        separated.push_bind_unseparated(emotion);
        first = false;
    }
    if let Some(is_private) = is_private {
        if !first {
            separated.push_unseparated(", ");
        }
        separated.push_unseparated("is_private = ");
        separated.push_bind_unseparated(is_private);
    }

    qry_builder.push(" WHERE id = ").push_bind(id);
    qry_builder.build().execute(tx).await?;
    Ok(())
}
