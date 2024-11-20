use super::client::SupabaseClient;

pub async fn get_diary_audio(
    supabase_client: SupabaseClient,
    audio_link: String,
) -> Result<Vec<u8>, reqwest::Error> {
    supabase_client
        .download("diary".to_string(), audio_link)
        .await
}
