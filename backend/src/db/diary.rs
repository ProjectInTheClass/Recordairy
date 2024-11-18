use serde::{Deserialize, Serialize};
use sqlx::{types::Uuid, PgPool};
use time::{Date, OffsetDateTime};

#[derive(Deserialize, Serialize, Debug)]
pub struct Diary {
    id: i64,
    created_at: OffsetDateTime,
    local_date: Date,
    user_id: Uuid,
    audio_link: String,
    summary: String,
    is_private: bool,
}

pub fn get_diaries_of_user(pool: PgPool) -> Vec<Diary> {
    todo!()
}
