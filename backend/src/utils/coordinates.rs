use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct Coordinates {
    x: i64,
    y: i64,
    z: i64,
    orientation: i32, // 4 directions: 0, 1, 2, 3
}
