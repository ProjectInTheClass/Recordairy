//
//  client.swift
//  Recordiary
//
//  Created by RulerOfCakes on 12/4/24.
//

import Alamofire
import Foundation

// let API_URL = "https://localhost:10000"
let API_URL = "https://recordiary.onrender.com"

enum APIError: Error {
    case responseError(String)
}

struct APIClient {
    // TODO: Credentials
    let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"  // Adjust format as needed
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }()

    func getDiary(userId: String, diaryId: Int64) async -> Result<
        DiaryModel, AFError
    > {
        let parameters: [String: Any] = [
            "user_id": userId,
            "diary_id": diaryId,
        ]
        return await withCheckedContinuation {
            continuation in
            AF.request(API_URL + "/diary", parameters: parameters)
                .responseDecodable(of: DiaryModel.self, decoder: decoder) {
                    response in
                    continuation.resume(returning: response.result)
                }
        }
    }

    func getCalendar(userId: String, year: Int64, month: Int64) async -> Result<
        [CalendarEntryModel], AFError
    > {
        let parameters: [String: Any] = [
            "user_id": userId,
            "year": year,
            "month": month,
        ]
        return await withCheckedContinuation {
            continuation in
            AF.request(API_URL + "/calendar", parameters: parameters)
                .responseDecodable(
                    of: [CalendarEntryModel].self, decoder: decoder
                ) {
                    response in
                    continuation.resume(returning: response.result)
                }
        }
    }

    func postDiary(userId: String, isPrivate: Bool, audioFile: Data) async
        -> Result<Int64, Error>
    {
        let is_private = if isPrivate { "true" } else { "false" }
        return await withCheckedContinuation {
            continuation in
            AF.upload(
                multipartFormData: { multipartFormData in
                    multipartFormData.append(
                        audioFile, withName: "audio_file",
                        fileName: "audio_file", mimeType: "audio/mp4")
                },
                to: API_URL
                    + "/diary?user_id=\(userId)&is_private=\(is_private)"
            ).responseString { response in
                switch response.result {
                case .success(let responseString):
                    if let intValue = Int64(responseString) {
                        continuation.resume(returning: .success(intValue))
                    } else {
                        continuation.resume(
                            returning: .failure(
                                APIError.responseError(responseString)))
                    }
                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }
    }

    func getFurniture(id: Int64) async -> Result<FurnitureModel, AFError> {
        let parameters: [String: Int64] = [
            "deco_id": id
        ]
        return await withCheckedContinuation {
            continuation in
            AF.request(API_URL + "/deco", parameters: parameters)
                .responseDecodable(of: FurnitureModel.self, decoder: decoder) {
                    response in
                    continuation.resume(returning: response.result)
                }
        }
    }

    func getAvailableFurniture() async -> Result<[FurnitureModel], AFError> {
        return await withCheckedContinuation {
            continuation in
            AF.request(API_URL + "/deco/available").responseDecodable(
                of: [FurnitureModel].self, decoder: decoder
            ) {
                response in
                continuation.resume(returning: response.result)
            }
        }
    }

    func getRoom(userId: String, year: Int32, month: Int32) async -> Result<
        [UserFurnitureModel], AFError
    > {
        let parameters: [String: Any] = [
            "user_id": userId,
            "year": year,
            "month": month,
        ]
        return await withCheckedContinuation {
            continuation in
            AF.request(API_URL + "/room", parameters: parameters)
                .responseDecodable(
                    of: [UserFurnitureModel].self, decoder: decoder
                ) {
                    response in
                    continuation.resume(returning: response.result)
                }
        }
    }

    // Call this when the user chooses a new furniture from their diary
    func postUserFurniture(userId: String, diaryId: Int32, decoId: Int32) async
        -> Result<Void, Error>
    {
        return await withCheckedContinuation {
            continuation in
            AF.request(
                API_URL
                    + "/room?user_id=\(userId)&diary_id=\(diaryId)&deco_id=\(decoId)",
                method: .post
            ).responseString {
                response in
                switch response.result {
                case .success(let responseString):
                    if responseString == "OK" {
                        continuation.resume(returning: .success(()))
                    } else {
                        continuation.resume(
                            returning: .failure(
                                APIError.responseError(responseString)))
                    }
                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }
    }

    func updateUserFurniture(
        userId: String, diaryId: Int32, decoId: Int32,
        coordinates: UserFurnitureModel.Coordinates?
    ) async -> Result<Void, Error> {
        return await withCheckedContinuation {
            continuation in
            AF.request(
                API_URL
                    + "/room?user_id=\(userId)&diary_id=\(diaryId)&deco_id=\(decoId)",
                method: .put
            ) {
                request in
                if let body = coordinates {
                    request.httpBody = try? JSONEncoder().encode(body)  // Encode the body if it exists
                    request.setValue(
                        "application/json", forHTTPHeaderField: "Content-Type")  // Set Content-Type header
                }
            }
            .responseString {
                response in
                switch response.result {
                case .success(let responseString):
                    if responseString == "OK" {
                        continuation.resume(returning: .success(()))
                    } else {
                        continuation.resume(
                            returning: .failure(
                                APIError.responseError(responseString)))
                    }
                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }
    }
}
