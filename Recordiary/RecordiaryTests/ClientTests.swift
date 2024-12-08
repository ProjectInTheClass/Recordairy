//
//  ClientTests.swift
//  Recordiary
//
//  Created by RulerOfCakes on 12/4/24.
//

import Testing
import AVFoundation
import Foundation
@testable import Recordiary

let TEST_USER_ID = "90ed0a4a-5b48-496d-844b-64f4b29c2b3b"

struct ClientTests {
    let client = APIClient()
    @Test func testGetDiary() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let result = await client.getDiary(userId: TEST_USER_ID, diaryId: 1)
        let diary = try result.get()
        #expect(diary.id == 1)
        
    }
    
    @Test func testGetFurniture() async throws {
        let result = await client.getFurniture(id: 1)
        let furniture = try result.get()
        
        #expect(furniture.id == 1)
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from:furniture.createdAt)
        #expect(components.year == 2024)
        #expect(components.month == 12)
        #expect(components.day == 3)
    }
    
    @Test func testGetRoom() async throws {
        let result = await client.getRoom(userId: TEST_USER_ID, year: 2024, month: 11)
        let room = try result.get()
        #expect(room.count == 2)
    }
    //   Don't use this function, only for verifying API
    //    @Test func testPostDiary() async throws {
    //        let data = Data()
    //        let result = await client.postDiary(userId: TEST_USER_ID, isPrivate: true, audioFile: data)
    //        let newId = try result.get()
    //        #expect(newId != 0)
    //    }
    
    @Test func postUserFurniture() async throws {
        let result = await client.postUserFurniture(userId: TEST_USER_ID, diaryId: 1, decoId: 1)
        let void = try result.get()
        #expect(void == ())
    }
    
    @Test func updateUserFurniture() async throws {
        let result = await client.updateUserFurniture(userId: TEST_USER_ID, diaryId: 1, decoId: 1, coordinates: UserFurnitureModel.Coordinates(x: 2, y: 2, z: 1, orientation: 1))
        let void = try result.get()
        #expect(void == ())
    }
}
