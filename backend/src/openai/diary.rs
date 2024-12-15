use std::sync::Arc;

use sqlx::PgPool;

use crate::{db::diary::update_diary, utils::sqlx::get_pg_tx};

use super::client::OpenAIClient;

pub async fn summarize_diary(
    pool: PgPool,
    client: Arc<OpenAIClient>,
    diary_id: i64,
    transcription: String,
) {
    let mut tx = get_pg_tx(pool).await.unwrap();

    let summary = client.summarize(&transcription).await.unwrap();
    let emotion = client.sentiment(&transcription).await.unwrap();
    let res = update_diary(
        &mut tx,
        diary_id,
        None,
        Some(summary),
        None,
        Some(emotion),
        None,
    )
    .await;

    let tx_res = match res {
        Ok(_) => tx.commit().await,
        Err(e) => {
            tracing::error!("Summarize error: {:?}", e);
            tx.rollback().await
        }
    };

    if let Err(e) = tx_res {
        tracing::error!("Summarize tx error: {:?}", e);
    }
}
