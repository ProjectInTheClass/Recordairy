use anyhow::anyhow;

use reqwest::{Client, Error as ReqwestError};
use serde_json::json;

#[derive(Debug, Clone)]
pub struct SupabaseClient {
    supabase_url: String,
    api_key: String,
    client: Client,
    audio_bucket: String,
    model_bucket: String,
}

impl SupabaseClient {
    pub fn new(
        supabase_url: String,
        api_key: String,
        audio_bucket: String,
        model_bucket: String,
    ) -> Self {
        // TODO: proper auth initialization
        Self {
            supabase_url,
            api_key,
            client: Client::new(),
            audio_bucket,
            model_bucket,
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

    pub async fn upload_diary(
        &self,
        audio: Vec<u8>,
        filename: &str,
    ) -> Result<String, anyhow::Error> {
        self.upload(self.audio_bucket.clone(), filename, audio)
            .await?;
        let presigned_suffix = self
            .get_presigned_download_url(self.audio_bucket.clone(), filename)
            .await?;

        Ok(format!(
            "{}/storage/v1/{}",
            self.supabase_url, presigned_suffix
        ))
    }

    pub async fn upload_model(
        &self,
        model: Vec<u8>,
        filename: &str,
    ) -> Result<String, anyhow::Error> {
        self.upload(self.model_bucket.clone(), filename, model)
            .await?;
        let presigned_suffix = self
            .get_presigned_download_url(self.model_bucket.clone(), filename)
            .await?;

        Ok(format!(
            "{}/storage/v1/{}",
            self.supabase_url, presigned_suffix
        ))
    }

    pub async fn upload(
        &self,
        bucket: String,
        filename: &str,
        file: Vec<u8>,
    ) -> Result<(), ReqwestError> {
        let url: String = format!(
            "{}/storage/v1/object/{}/{}",
            self.supabase_url, bucket, filename
        );

        let resp = self
            .client
            .post(&url)
            .header("apikey", &self.api_key)
            .header("authorization", &format!("Bearer {}", &self.api_key))
            .body(file)
            .send()
            .await?;

        match resp {
            r if r.status().is_success() => Ok(()),
            r => {
                tracing::error!("Error uploading file: {:?}", r);
                Err(r.error_for_status().unwrap_err())
            }
        }
    }
    pub async fn get_presigned_download_url(
        &self,
        bucket: String,
        filename: &str,
    ) -> Result<String, anyhow::Error> {
        let url = format!(
            "{}/storage/v1/object/sign/{}/{}",
            self.supabase_url, bucket, filename
        );

        let resp = self
            .client
            .post(&url)
            .header("apikey", &self.api_key)
            .header("authorization", &format!("Bearer {}", &self.api_key))
            .json(&json!({
                "expiresIn": 7776000, // 90 days
            })) // 90 days
            .send()
            .await?;

        let json = resp.json::<serde_json::Value>().await?;
        let Some(signed_url) = json["signedURL"].as_str() else {
            let error_message = json["message"].as_str().unwrap().to_string();
            return Err(anyhow!(error_message));
        };
        Ok(signed_url.to_string())
    }
}
