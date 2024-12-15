use std::{fs::File, io::Write};

use openai_api_rs::v1::{
    audio::AudioTranscriptionRequest,
    chat_completion::{ChatCompletionMessage, ChatCompletionRequest, Content, MessageRole},
};

pub enum Emotion {
    Anger,
    Sadness,
    Happiness,
    Neutral,
}

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
        let resp = self.openai.audio_transcription(request).await?;
        Ok(resp.text)
    }

    pub async fn summarize(&self, content: &str) -> anyhow::Result<String> {
        let request = ChatCompletionRequest {
            model: "gpt-3.5-turbo".to_string(),
            messages: vec![ChatCompletionMessage {
                role: MessageRole::system,
                content: Content::Text(
                    "Summarize the following text in korean: ".to_string() + content,
                ),
                name: None,
                tool_call_id: None,
                tool_calls: None,
            }],
            temperature: Some(0.0),
            top_p: None,
            n: None,
            response_format: None,
            stream: None,
            stop: None,
            max_tokens: Some(50),
            presence_penalty: None,
            frequency_penalty: None,
            logit_bias: None,
            user: None,
            seed: None,
            tools: None,
            parallel_tool_calls: None,
            tool_choice: None,
        };
        let resp = self.openai.chat_completion(request).await?;
        Ok(resp.choices[0]
            .message
            .content
            .clone()
            .unwrap_or("".to_string())
            .to_string())
    }

    pub async fn sentiment(&self, content: &str) -> anyhow::Result<String> {
        let base_prompt = "Analyze the sentiment of the following korean text. 
        Only respond with one of the following choices: anger, sadness, happiness, neutral.
        Target text: ";
        let request = ChatCompletionRequest {
            model: "gpt-3.5-turbo".to_string(),
            messages: vec![ChatCompletionMessage {
                role: MessageRole::system,
                content: Content::Text(base_prompt.to_string() + content),
                name: None,
                tool_call_id: None,
                tool_calls: None,
            }],
            temperature: Some(0.0),
            top_p: None,
            n: None,
            response_format: None,
            stream: None,
            stop: None,
            max_tokens: Some(50),
            presence_penalty: None,
            frequency_penalty: None,
            logit_bias: None,
            user: None,
            seed: None,
            tools: None,
            parallel_tool_calls: None,
            tool_choice: None,
        };
        let resp = self.openai.chat_completion(request).await?;
        let raw_emotion = resp.choices[0]
            .message
            .content
            .clone()
            .unwrap_or("neutral".to_string())
            .to_string();
        Ok(raw_emotion)
    }
}

impl Default for OpenAIClient {
    fn default() -> Self {
        Self::new()
    }
}
