//
//  SocialViewModel.swift
//  Recordiary
//
//  Created by 김민아 on 12/10/24.
//


import SwiftUI

class SocialViewModel: ObservableObject {
    @Published var friends: [String] = ["친구1", "친구2", "친구3"]
    @Published var friendCodeInput = ""
    
    // 친구 추가 로직
    func addFriend() {
        guard !friendCodeInput.isEmpty else { return }
        friends.append("새 친구 (\(friendCodeInput))")
        friendCodeInput = ""
    }
    
    // 친구 삭제 로직
    func deleteFriend(at index: Int) {
        friends.remove(at: index)
    }
}
