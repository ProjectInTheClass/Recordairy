use axum::{
    debug_handler,
    extract::{Multipart, Query, State},
    response::IntoResponse,
};
use hyper::StatusCode;
use serde::Deserialize;
use sqlx::PgPool;

use crate::{
    db::deco::Deco,
    storage::client::SupabaseClient,
    utils::{parse_multipart::parse_multipart, sqlx::get_pg_tx},
    AppState,
};

#[derive(Deserialize, Clone, Debug)]
pub struct GetDecoParams {
    deco_id: i64,
}

pub struct GetDecoRseponse(Deco);

impl IntoResponse for GetDecoRseponse {
    fn into_response(self) -> axum::response::Response {
        let deco = self.0;
        let serialized = serde_json::to_string(&deco);

        match serialized {
            Ok(serialized) => (StatusCode::OK, serialized).into_response(),
            Err(e) => (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()).into_response(),
        }
    }
}

#[debug_handler(state = AppState)]
pub async fn get_deco(
    State(pool): State<PgPool>,
    Query(params): Query<GetDecoParams>,
) -> axum::response::Result<GetDecoRseponse> {
    let mut tx = get_pg_tx(pool).await?;
    let deco = crate::db::deco::get_deco(&mut tx, params.deco_id).await;
    match deco {
        Ok(deco) => {
            if let Err(e) = tx.commit().await {
                Err(e.to_string().into())
            } else {
                Ok(GetDecoRseponse(deco))
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

#[derive(Deserialize, Clone, Debug)]
pub struct CreateDecoParams {
    name: String,
    display_name: Option<String>,
    category: Option<String>,
    is_valid: bool,
}

pub struct CreateDecoResponse(Deco);

impl IntoResponse for CreateDecoResponse {
    fn into_response(self) -> axum::response::Response {
        let deco = self.0;
        let serialized = serde_json::to_string(&deco);

        match serialized {
            Ok(serialized) => (StatusCode::OK, serialized).into_response(),
            Err(e) => (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()).into_response(),
        }
    }
}

#[debug_handler(state = AppState)]
pub async fn create_deco(
    State(pool): State<PgPool>,
    State(storage_client): State<SupabaseClient>,
    Query(params): Query<CreateDecoParams>,
    multipart: Multipart,
) -> axum::response::Result<CreateDecoResponse> {
    let mut tx = get_pg_tx(pool).await?;

    let result: anyhow::Result<Deco> = async {
        let (model_bytes, _model_metadata) = match parse_multipart(multipart).await {
            Ok(model_data) => model_data,
            Err(e) => return Err(e),
        };
        // upload model to storage
        let url = storage_client
            .upload_model(model_bytes.to_vec(), params.name.clone())
            .await?;

        let deco = crate::db::deco::create_deco(
            &mut tx,
            crate::db::deco::CreateDecoParams {
                name: params.name,
                display_name: params.display_name,
                category: params.category,
                asset_link: url,
                is_valid: params.is_valid,
            },
        )
        .await?;
        Ok(deco)
    }
    .await;
    match result {
        Ok(result) => {
            if let Err(e) = tx.commit().await {
                Err(e.to_string().into())
            } else {
                Ok(CreateDecoResponse(result))
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

pub struct GetAvailableDecosResponse(Vec<Deco>);
impl IntoResponse for GetAvailableDecosResponse {
    fn into_response(self) -> axum::response::Response {
        let decos = self.0;
        let serialized = serde_json::to_string(&decos);

        match serialized {
            Ok(serialized) => (StatusCode::OK, serialized).into_response(),
            Err(e) => (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()).into_response(),
        }
    }
}

#[debug_handler(state = AppState)]
pub async fn get_available_decos(
    State(pool): State<PgPool>,
) -> axum::response::Result<GetAvailableDecosResponse> {
    let mut tx = get_pg_tx(pool).await?;
    let decos = crate::db::deco::get_available_decos(&mut tx).await;
    match decos {
        Ok(decos) => {
            if let Err(e) = tx.commit().await {
                Err(e.to_string().into())
            } else {
                Ok(GetAvailableDecosResponse(decos))
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
