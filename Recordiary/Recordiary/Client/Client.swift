//
//  client.swift
//  Recordiary
//
//  Created by RulerOfCakes on 12/4/24.
//

import Alamofire
import Foundation

let API_URL = "https://recordiary.onrender.com"

struct APIClient {
    // TODO: Credentials
    let decoder : JSONDecoder = {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ" // Adjust format as needed
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }()
    
    func getDiary(userId: String, diaryId: Int64) async -> Result<DiaryModel,AFError> {
        let parameters: [String: Any] = [
            "user_id": userId,
            "diary_id": diaryId
        ];
        return await withCheckedContinuation {
            continuation in AF.request(API_URL+"/diary", parameters:parameters ).responseDecodable(of: DiaryModel.self, decoder:decoder) {
                response in
                continuation.resume(returning: response.result)
            }
        }
    }
    
    func getFurniture(id: Int64) async -> Result<FurnitureModel, AFError> {
        let parameters:[String:Int64] = [
            "deco_id": id
        ];
        return await withCheckedContinuation {
            continuation in AF.request(API_URL+"/deco",parameters: parameters)
                .responseDecodable(of:FurnitureModel.self, decoder:decoder) {
                    response in
                    continuation.resume(returning: response.result)
                }
        }
    }
}
