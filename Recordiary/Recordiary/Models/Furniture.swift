//
//  Furniture.swift
//  Recordiary
//
//  Created by RulerOfCakes on 12/4/24.
//
import Foundation

// FurnitureModel describes a singular furniture model.
// To know about where the furniture is placed in a user's room,
// refer to UserFurnitureModel.
struct FurnitureModel: Decodable {
    let id: Int
    let createdAt: Date
    let updatedAt: Date
    let name: String
    let assetLink: String
    let category: String
    let isValid: Bool
    let displayName: String?

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case name
        case assetLink = "asset_link"
        case category
        case isValid = "is_valid"
        case displayName = "display_name"
    }
}

struct UserFurnitureModel: Decodable {
    let userId: String
    let decoId: Int
    let name: String
    let assetLink: String
    let category: String
    let displayName: String?
    let diaryId: Int
    let createdAt: Date
    let localDate: String
    let audioLink: String
    let summary: String?
    let isPrivate: Bool
    let isPlaced: Bool
    let coordinates: Coordinates?

    struct Coordinates: Decodable, Encodable {
        let x: Int
        let y: Int
        let z: Int
        let orientation: Int
    }

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case decoId = "deco_id"
        case name
        case assetLink = "asset_link"
        case category
        case displayName = "display_name"
        case diaryId = "diary_id"
        case createdAt = "created_at"
        case localDate = "local_date"
        case audioLink = "audio_link"
        case summary
        case isPrivate = "is_private"
        case isPlaced = "is_placed"
        case coordinates
    }
}
