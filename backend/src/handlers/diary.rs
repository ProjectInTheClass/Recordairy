use axum::{
    debug_handler,
    extract::{Multipart, Query, State},
    response::IntoResponse,
};
use serde::Deserialize;
use sqlx::PgPool;
use uuid::Uuid;

use crate::{
    db::diary::insert_diary,
    storage::client::SupabaseClient,
    utils::{get_diary_filename, parse_multipart::parse_multipart},
    AppState,
};

struct Diary();

pub async fn get_diaries() -> Vec<Diary> {
    todo!()
}

pub struct CreateDiaryResponse(anyhow::Result<()>);

impl IntoResponse for CreateDiaryResponse {
    fn into_response(self) -> axum::response::Response {
        todo!()
    }
}

#[derive(Deserialize, Debug)]
pub struct CreateDiaryParams {
    user_id: Uuid,
    is_private: Option<bool>,
}

#[debug_handler(state = AppState)]
pub async fn create_diary(
    State(pool): State<PgPool>,
    State(storage_client): State<SupabaseClient>,
    Query(params): Query<CreateDiaryParams>,
    multipart: Multipart,
) -> axum::response::Result<()> {
    let mut tx = match pool.begin().await {
        Ok(tx) => tx,
        Err(e) => return Err(e.to_string().into()),
    };
    let result: anyhow::Result<()> = async {
        let audio_bytes = match parse_multipart(multipart).await {
            Ok(audio_bytes) => audio_bytes,
            Err(e) => return Err(e),
        };
        // upload diary to database first to retrieve ID
        let diary_id = insert_diary(
            &mut tx,
            crate::db::diary::DiaryParams::new(
                params.user_id,
                None,
                None,
                params.is_private.unwrap_or(false),
            ),
        )
        .await?;
        storage_client
            .upload_diary(
                audio_bytes.to_vec(),
                get_diary_filename(params.user_id, diary_id),
            )
            .await?;

        Ok(())
    }
    .await;

    match result {
        Ok(_) => {
            if let Err(e) = tx.commit().await {
                Err(e.to_string().into())
            } else {
                Ok(())
            }
        }
        Err(e) => {
            if let Err(rollback_e) = tx.rollback().await {
                tracing::error!("Failed to rollback transaction: {}", rollback_e);
            }
            Err(e.to_string().into())
        }
    }
}
