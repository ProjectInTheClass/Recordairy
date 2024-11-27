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
    storage::client::SupabaseClient,
    utils::{get_diary_filename, parse_multipart::parse_multipart},
    AppState,
};

#[derive(Deserialize, Clone, Debug)]
pub struct GetDiariesParams {
    user_id: Uuid,
    diary_ids: Vec<i64>,
}

pub struct GetDiariesRseponse(Vec<Diary>);

impl IntoResponse for GetDiariesRseponse {
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
pub async fn get_diaries(
    State(pool): State<PgPool>,
    Query(params): Query<GetDiariesParams>,
) -> axum::response::Result<GetDiariesRseponse> {
    let diaries = crate::db::diary::get_diaries(&pool, params.user_id, params.diary_ids).await;
    match diaries {
        Ok(diaries) => Ok(GetDiariesRseponse(diaries)),
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
    State(storage_client): State<SupabaseClient>,
    Query(params): Query<CreateDiaryParams>,
    multipart: Multipart,
) -> axum::response::Result<String> {
    let mut tx = match pool.begin().await {
        Ok(tx) => tx,
        Err(e) => return Err(e.to_string().into()),
    };
    let result: anyhow::Result<_> = async {
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
        let audio_link = storage_client
            .upload_diary(
                audio_bytes.to_vec(),
                get_diary_filename(params.user_id, diary_id),
            )
            .await?;

        update_diary(&mut tx, diary_id, Some(audio_link), None, None).await?;
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
