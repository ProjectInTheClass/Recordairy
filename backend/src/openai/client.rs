use std::{fs::File, io::Write};

use openai_api_rs::v1::audio::AudioTranscriptionRequest;

pub struct OpenAIClient {
    openai: openai_api_rs::v1::api::OpenAIClient,
}

impl OpenAIClient {
    pub fn new() -> Self {
        Self {
            openai: openai_api_rs::v1::api::OpenAIClient::builder()
                .with_api_key(std::env::var("OPENAI_API_KEY").unwrap())
                .build()
                .expect("Failed to create OpenAI client"),
        }
    }

    pub async fn transcribe(
        &self,
        audio_title: &str,
        audio_content: &[u8],
    ) -> anyhow::Result<String> {
        let tmp_dir = tempfile::tempdir()?; // the directory will be dropped with the lifetime
        let tmp_path = tmp_dir.path().join(audio_title);
        let mut audio_file = File::create(tmp_path.clone())?;

        audio_file.write_all(audio_content)?;
        audio_file.flush()?;
        let request = AudioTranscriptionRequest {
            file: tmp_path.to_string_lossy().to_string(),
            model: "whisper-1".to_string(),
            prompt: None,
            response_format: Some("json".to_string()),
            temperature: None,
            language: Some("ko".to_string()),
        };
        let resp = self.openai.audio_transcription(request).await;
        match resp {
            Ok(resp) => Ok(resp.text),
            Err(e) => Err(anyhow::anyhow!("Failed to transcribe audio: {:?}", e)),
        }
    }
}

impl Default for OpenAIClient {
    fn default() -> Self {
        Self::new()
    }
}
