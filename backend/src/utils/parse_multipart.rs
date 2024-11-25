use axum::{body::Bytes, extract::Multipart};

pub async fn parse_multipart(mut multipart: Multipart) -> anyhow::Result<Bytes> {
    if let Some(field) = multipart.next_field().await? {
        let _name = field.name().unwrap_or("").to_string();
        let _file_name = field.file_name().unwrap_or("").to_string();
        let _content_type = field.content_type().unwrap_or("").to_string();
        let data = field.bytes().await?;

        Ok(data)
    } else {
        Err(anyhow::anyhow!("No file uploaded"))
    }
}
