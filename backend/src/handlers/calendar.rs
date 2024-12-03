use axum::{
    extract::{Query, State},
    response::{IntoResponse, Response},
};
use hyper::StatusCode;
use serde::{Deserialize, Serialize};
use sqlx::PgPool;
use time::OffsetDateTime;
use uuid::Uuid;

use crate::db::diary::{get_diaries_of_month, Diary};

#[derive(Deserialize, Debug)]
pub struct GetCalendarParams {
    user_id: Uuid,
    year: u32,
    month: u32,
}

#[derive(Deserialize, Serialize, Debug)]
struct CalendarData {
    #[serde(with = "time::serde::rfc3339")]
    created_at: OffsetDateTime,
    diary: Diary,
}

pub struct CalendarDataResponse(anyhow::Result<Vec<CalendarData>>);

impl IntoResponse for CalendarDataResponse {
    fn into_response(self) -> Response {
        let Ok(resp) = &self.0 else {
            let e = &self.0.unwrap_err();
            return (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()).into_response();
        };
        let serialized = serde_json::to_string(resp);
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

// fetch all calendar entries for the given user & year & month
pub async fn get_calendar(
    State(pool): State<PgPool>,
    Query(params): Query<GetCalendarParams>,
) -> CalendarDataResponse {
    let diaries = match get_diaries_of_month(&pool, params.year, params.month, params.user_id).await
    {
        Ok(diaries) => diaries,
        Err(e) => return CalendarDataResponse(Err(e)),
    };
    CalendarDataResponse(Ok(diaries
        .into_iter()
        .map(|d| CalendarData {
            created_at: d.created_at,
            diary: d,
        })
        .collect()))
}
