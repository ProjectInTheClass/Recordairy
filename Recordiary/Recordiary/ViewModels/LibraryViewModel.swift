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
    @Published var filterMode: FilterMode = .all // 필터 모드

    // 전체 가구 데이터
    private var allFurniture: [Furniture] = furnitureDummyData

    var ownedFurnitures: [Furniture] {
        allFurniture.filter { $0.quantity > 0 }
    }

    // 필터링된 가구 목록
    var filteredItems: [Furniture] {
        let baseItems: [Furniture]
        switch filterMode {
        case .all:
            baseItems = allFurniture
        case .unowned:
            baseItems = allFurniture.filter { $0.quantity == 0 }
        }

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

    func decreaseFurnitureQuantity(for furniture: Furniture) -> Bool {
        guard let index = allFurniture.firstIndex(where: { $0.id == furniture.id }) else {
            return false // 가구를 찾을 수 없으면 실패
        }

        if allFurniture[index].quantity > 0 {
            allFurniture[index].quantity -= 1
            return true // 성공적으로 수량 감소
        }

        return false // 수량이 0이어서 감소 불가
    }
    
    func increaseFurnitureQuantity(for furniture: Furniture) {
        guard let index = allFurniture.firstIndex(where: { $0.id == furniture.id }) else { return }
        allFurniture[index].quantity += 1
    }
}
