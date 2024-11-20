use reqwest::{Client, Error as ReqwestError};

#[derive(Debug, Clone)]
pub struct SupabaseClient {
    supabase_url: String,
    api_key: String,
    client: Client,
}

impl SupabaseClient {
    pub fn new(supabase_url: String, api_key: String) -> Self {
        // TODO: proper auth initialization
        Self {
            supabase_url,
            api_key,
            client: Client::new(),
        }
    }

    pub async fn download(
        &self,
        bucket: String,
        filename: String,
    ) -> Result<Vec<u8>, ReqwestError> {
        let url: String = format!(
            "{}/storage/v1/object/public/{}/{}",
            self.supabase_url, bucket, filename
        );
        let resp = self.client.get(&url).send().await?;

        Ok(resp.bytes().await?.to_vec())
    }
}
