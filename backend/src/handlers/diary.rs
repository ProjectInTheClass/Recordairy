use std::sync::Arc;

use axum::{
    debug_handler,
    extract::{Multipart, Query, State},
    response::IntoResponse,
};
use hyper::StatusCode;
use serde::Deserialize;
use sqlx::PgPool;
use uuid::Uuid;

use crate::{
    db::diary::{insert_diary, update_diary, Diary},
    openai::client::OpenAIClient,
    storage::client::SupabaseClient,
    utils::{get_diary_filename, parse_multipart::parse_multipart, sqlx::get_pg_tx},
    AppState,
};

#[derive(Deserialize, Clone, Debug)]
pub struct GetDiaryParams {
    user_id: Uuid,
    diary_id: i64,
}

pub struct GetDiaryRseponse(Diary);

impl IntoResponse for GetDiaryRseponse {
    fn into_response(self) -> axum::response::Response {
        let diaries = self.0;
        let serialized = serde_json::to_string(&diaries);

        match serialized {
            Ok(serialized) => (StatusCode::OK, serialized).into_response(),
            Err(e) => (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()).into_response(),
        }
    }
}

#[debug_handler(state = AppState)]
pub async fn get_diary(
    State(pool): State<PgPool>,
    Query(params): Query<GetDiaryParams>,
) -> axum::response::Result<GetDiaryRseponse> {
    let diary = crate::db::diary::get_diaries(&pool, params.user_id, vec![params.diary_id]).await;
    match diary {
        Ok(diaries) => Ok(GetDiaryRseponse(diaries[0].clone())),
        Err(e) => Err(e.to_string().into()),
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
    State(openai_client): State<Arc<OpenAIClient>>,
    State(storage_client): State<SupabaseClient>,
    Query(params): Query<CreateDiaryParams>,
    multipart: Multipart,
) -> axum::response::Result<String> {
    let mut tx = get_pg_tx(pool.clone()).await?;
    let result: anyhow::Result<_> = async {
        let (audio_bytes, _audio_metadata) = match parse_multipart(multipart).await {
            Ok(audio_data) => audio_data,
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
        let audio_title = get_diary_filename(params.user_id, diary_id);
        let audio_link = storage_client
            .upload_diary(audio_bytes.to_vec(), &audio_title)
            .await?;
        update_diary(&mut tx, diary_id, Some(audio_link), None, None, None).await?;

        // create a background subtask to transcribe the audio
        tokio::spawn(async move {
            let mut tx = get_pg_tx(pool).await.unwrap();
            match openai_client.transcribe(&audio_title, &audio_bytes).await {
                Ok(audio_transcription) => {
                    if let Err(e) = update_diary(
                        &mut tx,
                        diary_id,
                        None,
                        None,
                        Some(audio_transcription),
                        None,
                    )
                    .await
                    {
                        tracing::error!("Failed to update diary with transcription: {}", e);
                    }
                }
                Err(e) => {
                    tracing::error!("Failed to transcribe audio: {}", e);
                }
            }

            if let Err(e) = tx.commit().await {
                tracing::error!("Failed to commit transaction: {}", e);
            };
        });

        Ok(diary_id)
    }
    .await;

    match result {
        Ok(id) => {
            if let Err(e) = tx.commit().await {
                Err(e.to_string().into())
            } else {
                Ok(id.to_string())
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
