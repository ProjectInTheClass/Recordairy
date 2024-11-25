use uuid::Uuid;

pub mod internal_error;
pub mod parse_multipart;

pub fn get_diary_filename(user_id: Uuid, diary_id: i64) -> String {
    // TODO: check file extension?
    return user_id.to_string() + "_" + &diary_id.to_string() + ".mp3";
}
