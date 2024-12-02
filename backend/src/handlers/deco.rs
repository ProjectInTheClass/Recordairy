use axum::{
    debug_handler,
    extract::{Query, State},
    response::IntoResponse,
};
use hyper::StatusCode;
use serde::Deserialize;
use sqlx::PgPool;

use crate::{
    db::deco::{get_deco, Deco},
    utils::sqlx::get_pg_tx,
    AppState,
};

#[derive(Deserialize, Clone, Debug)]
pub struct GetDecoParams {
    deco_id: i64,
}

pub struct GetDecoRseponse(Deco);

impl IntoResponse for GetDecoRseponse {
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
    Query(params): Query<GetDecoParams>,
) -> axum::response::Result<GetDecoRseponse> {
    let mut tx = get_pg_tx(pool).await?;
    let deco = get_deco(&mut tx, params.deco_id).await;
    match deco {
        Ok(deco) => Ok(GetDecoRseponse(deco)),
        Err(e) => Err(e.to_string().into()),
    }
}
