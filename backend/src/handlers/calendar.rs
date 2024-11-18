use axum::{
    extract::{Query, State},
    response::{IntoResponse, Response},
};
use hyper::StatusCode;
use serde::{Deserialize, Serialize};
use sqlx::PgPool;

use crate::db::diary::Diary;

#[derive(Deserialize, Debug)]
pub struct GetCalendarParams {
    user_id: String,
    year: u32,
    month: u32,
}

#[derive(Deserialize, Serialize, Debug)]
struct CalendarData {
    created_at: String,
    diary: Diary,
}

pub struct CalendarDataResponse(Vec<CalendarData>);

impl IntoResponse for CalendarDataResponse {
    fn into_response(self) -> Response {
        let serialized = serde_json::to_string(&self.0);
        if let Ok(serialized) = serialized {
            (StatusCode::OK, serialized).into_response()
        } else {
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                "Failed to serialize response",
            )
                .into_response()
        }
    }
}

pub async fn get_calendar(
    State(pool): State<PgPool>,
    Query(params): Query<GetCalendarParams>,
) -> CalendarDataResponse {
    dbg!(params);

    todo!()
}
