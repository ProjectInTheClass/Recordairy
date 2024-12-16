//
//  StructFile.swift
//  Recordiary
//
//  Created by 김민아 on 12/3/24.
//

import SwiftUI

//기본 가구 구조체
struct Furniture: Identifiable {
    let id = UUID() // 고유 ID
    let name: String
    let display_name: String
    let img: URL    //미리보기에 들어감
    let asset_link: URL
    let category: FurnitureType
    var quantity: Int
}

//일기와 연결된 가구
struct DiaryConnectedFurniture: Identifiable {
    var id = UUID()
    var furniture: Furniture
    var diary: DiaryEntry
    var created_at: Date
    var is_set: Bool
    var is_vaild: Bool
    // 방 안에서의 좌표와 방향
    var position: (x: Int, y: Int)?
    var direction: Int?
}

//기본 일기 구조체
struct DiaryEntry: Identifiable {
    var id: Int
    var user_id: String
    var created_at: Date
    var local_date: String
    var emotion: Emotion
    var audio_link: URL
    var keyWord: String
    var transcribedText: String
    var is_private: Bool
    var connectedFurniture: Furniture?
}

// 감정 및 DiaryEntry 모델 정의
enum Emotion: String, Codable, CaseIterable {
    case anger = "화남"
    case sadness = "슬픔"
    case happiness = "행복"
    case neutral = "편안"

    var color: Color {
        switch self {
        case .anger: return Color(hex: "#E57373")
        case .sadness: return Color(hex: "#A68DBF")
        case .happiness: return Color(hex: "#F2CD00")
        case .neutral: return Color(hex: "#81C784")
        }
    }
}

//가구 타입
enum FurnitureType: String, Codable {
    case wall = "벽"
    case floor = "바닥"
    case wallMounted = "벽에 붙이는"
    case floorRug = "바닥에 까는"
    case generalFurniture = "일반 가구"
    case supportingFurniture = "작은 물건 올릴 수 있는 가구" // 자신 위에 물건 올릴 수 있는 가구
    case smallItem = "작은 물건"       // 위의 가구 위에 놓이는 작은 물건
}

