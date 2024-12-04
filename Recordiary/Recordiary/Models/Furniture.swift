//
//  Furniture.swift
//  Recordiary
//
//  Created by RulerOfCakes on 12/4/24.
//

struct FurnitureModel: Decodable {
    let id: Int
    let createdAt: String
    let updatedAt: String
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
