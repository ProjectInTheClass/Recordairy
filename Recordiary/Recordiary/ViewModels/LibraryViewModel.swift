//
//  LibraryViewModel.swift
//  Recordiary
//
//  Created by 김민아 on 11/19/24.
//

import SwiftUI

enum FilterMode {
    case all
    case unowned
}

class LibraryViewModel: ObservableObject {
    @Published var isLibrarySheetPresented: Bool = false // 모달 상태
    @Published var searchText: String = "" // 검색창 텍스트
    @Published var isRecording: Bool = false // 녹음 상태
    @Published var filterMode: FilterMode = .all // 필터 모드

    private let furnitureItems = Array(1...20).map { "가구 \($0)" } // 가구 정보 목록
    private let unownedItems = ["가구 3", "가구 7", "가구 15"] // 미보유 가구 목록
    
    func isOwned(item: String) -> Bool {
        return !unownedItems.contains(item) // 미보유 목록에 없으면 보유 중
    }

    var filteredItems: [String] {
        let baseItems: [String]
        switch filterMode {
        case .all:
            baseItems = furnitureItems
        case .unowned:
            baseItems = unownedItems
        }

        if searchText.isEmpty {
            return baseItems
        } else {
            return baseItems.filter { $0.contains(searchText) }
        }
    }

    func toggleRecording() {
        isRecording.toggle() // 녹음 상태 토글
    }
}
