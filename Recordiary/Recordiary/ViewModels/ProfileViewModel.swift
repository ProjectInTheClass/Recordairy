//
//  ProfileViewModel.swift
//  Recordiary
//
//  Created by 권동민 on 12/11/24.
//
import SwiftUI

class Profile: ObservableObject {
    @Published var userName: String
    @Published var profileImage: UIImage?

    init(userName: String = "사용자 이름", profileImage: UIImage? = nil) {
        self.userName = userName
        self.profileImage = profileImage
    }
}

