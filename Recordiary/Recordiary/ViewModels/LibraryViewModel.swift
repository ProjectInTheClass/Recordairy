//
//  LibraryViewModel.swift
//  Recordiary
//
//  Created by 김민아 on 11/19/24.
//

import SwiftUI

class LibraryViewModel: ObservableObject {
    @Published var isLibrarySheetPresented: Bool = false // 모달 상태
    @Published var searchText: String = "" // 검색창 텍스트
    @Published var isRecording: Bool = false // 녹음 상태

    private let furnitureItems = Array(1...20).map { "가구 \($0)" } // 가구 정보 목록

    var filteredItems: [String] {
        if searchText.isEmpty {
            return furnitureItems
        } else {
            return furnitureItems.filter { $0.contains(searchText) }
        }
    }

    func toggleRecording() {
        isRecording.toggle() // 녹음 상태 토글
    }
}
