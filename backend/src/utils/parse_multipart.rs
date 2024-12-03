use axum::{body::Bytes, extract::Multipart};

pub struct MultipartMetadata {
    pub name: String,
    pub file_name: String,
    pub content_type: String,
}

pub async fn parse_multipart(
    mut multipart: Multipart,
) -> anyhow::Result<(Bytes, MultipartMetadata)> {
    if let Some(field) = multipart.next_field().await? {
        // TODO: robust way of attaching names to files
        let name = field.name().unwrap_or("").to_string();
        let file_name = field.file_name().unwrap_or("").to_string();
        let content_type = field.content_type().unwrap_or("").to_string();
        let metadata = MultipartMetadata {
            name,
            file_name,
            content_type,
        };
        let data = field.bytes().await?;

        Ok((data, metadata))
    } else {
        Err(anyhow::anyhow!("No file uploaded"))
    }
}
