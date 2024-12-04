//
//  ClientTests.swift
//  Recordiary
//
//  Created by RulerOfCakes on 12/4/24.
//

import Testing
import Foundation
@testable import Recordiary

let TEST_USER_ID = "90ed0a4a-5b48-496d-844b-64f4b29c2b3b"

struct ClientTests {

    @Test func testGetDiary() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let client = APIClient()
        let result = await client.getDiary(userId: TEST_USER_ID, diaryId: 1)
        let diary = try result.get()
        #expect(diary.id == 1)
        
    }

}
