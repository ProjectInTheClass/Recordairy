//
//  Diary.swift
//  Recordiary
//
//  Created by RulerOfCakes on 12/4/24.
//

import Foundation

struct DiaryModel: Decodable {
    let id: Int
    let createdAt: Date
    let localDate: String
    let userId: String
    let audioLink: String
    let summary: String?
    let isPrivate: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case localDate = "local_date"
        case userId = "user_id"
        case audioLink = "audio_link"
        case summary
        case isPrivate = "is_private"
    }
}
