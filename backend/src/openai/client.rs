use std::{fs::File, io::Write};

use openai_api_rust::{
    audio::{AudioApi, AudioBody},
    Auth, OpenAI,
};

#[derive(Debug, Clone)]
pub struct OpenAIClient {
    openai: OpenAI,
}

impl OpenAIClient {
    pub fn new() -> Self {
        let auth = Auth::from_env().unwrap();
        let openai = OpenAI::new(auth, "https://api.openai.com/v1/");
        Self { openai }
    }

    pub fn transcribe(&self, audio_title: &str, audio_content: &[u8]) -> anyhow::Result<String> {
        let tmp_dir = tempfile::tempdir()?;
        let tmp_path = tmp_dir.path().join(audio_title);
        let mut audio_file = File::create(tmp_path.clone())?;

        audio_file.write_all(audio_content)?;
        audio_file.flush()?;
        let audio_file = File::open(tmp_path)?;
        dbg!(&audio_file);
        let audio_body: AudioBody = AudioBody {
            file: audio_file.try_clone()?,
            model: "whisper-1".to_string(),
            prompt: None,
            response_format: Some("text".to_string()),
            temperature: None,
            language: Some("ko".to_string()),
        };
        let result = self.openai.audio_transcription_create(audio_body);
        drop(audio_file);
        tmp_dir.close()?;
        match result {
            Ok(audio) => {
                if let Some(transcription) = audio.text {
                    Ok(transcription)
                } else {
                    Err(anyhow::anyhow!(
                        "Failed to transcribe audio: empty response"
                    ))
                }
            }
            Err(e) => Err(anyhow::anyhow!("Failed to transcribe audio: {:?}", e)),
        }
    }
}

impl Default for OpenAIClient {
    fn default() -> Self {
        Self::new()
    }
}
