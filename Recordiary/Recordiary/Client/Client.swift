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
    
    func postDiary(userId: String, isPrivate: Bool, audioFile: Data) async -> Result<Int64, AFError>{
        return await withCheckedContinuation {
            continuation in
            AF.upload(
                multipartFormData: { multipartFormData in
                    multipartFormData.append(userId.data(using: .utf8)!, withName: "user_id")
                    let is_private = if isPrivate {"true"}else {"false"}
                    multipartFormData.append(is_private.data(using:.utf8)!,withName:"is_private")
                    // Add the audio file data
                    multipartFormData.append(audioFile, withName: "audio_file", fileName: "audio_file", mimeType: "audio/mpeg")
                }, to: API_URL + "/diary").responseDecodable(of: Int64.self) { response in
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
    
    func getAvailableFurniture() async -> Result<[FurnitureModel], AFError > {
        return await withCheckedContinuation {
            continuation in AF.request(API_URL+"/deco/available").responseDecodable(of: [FurnitureModel].self, decoder:decoder) {
                response in
                continuation.resume(returning: response.result)
            }
        }
    }
    
    func getRoom(userId: String, year: Int32, month: Int32) async -> Result<[UserFurnitureModel],AFError >{
        let parameters: [String: Any] = [
            "user_id": userId,
            "year": year,
            "month": month
        ]
        return await withCheckedContinuation {
            continuation in AF.request(API_URL + "/room", parameters:parameters)
                .responseDecodable(of: [UserFurnitureModel].self, decoder:decoder) {
                    response in
                    continuation.resume(returning: response.result)
                }
        }
    }
}
