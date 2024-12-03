use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct Coordinates {
    pub x: i64,
    pub y: i64,
    pub z: i64,
    pub orientation: i32, // 4 directions: 0, 1, 2, 3
}
