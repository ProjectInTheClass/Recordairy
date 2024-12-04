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
    @Published var searchText: String = "" // 검색 텍스트
    @Published var isRecording: Bool = false // 녹음 상태
    @Published var filterMode: FilterMode = .all // 필터 모드

    // 전체 가구 데이터
    private var allFurniture: [Furniture] = furnitureDummyData

    // 필터링된 가구 목록
    var filteredItems: [Furniture] {
        // 필터 모드에 따른 기본 데이터 설정
        let baseItems: [Furniture]
        switch filterMode {
        case .all:
            baseItems = allFurniture
        case .unowned:
            baseItems = allFurniture.filter { $0.quantity == 0 } // 미보유 가구 필터링
        }

        // 검색 텍스트 필터링 적용
        if searchText.isEmpty {
            return baseItems
        } else {
            return baseItems.filter { $0.display_name.contains(searchText) }
        }
    }

    // 특정 가구의 보유 여부 확인
    func isOwned(item: Furniture) -> Bool {
        item.quantity > 0
    }

    // 특정 가구의 보유 수량 반환
    func ownedQuantity(for item: Furniture) -> Int {
        item.quantity
    }

    // 녹음 상태 토글
    func toggleRecording() {
        isRecording.toggle()
    }
}
