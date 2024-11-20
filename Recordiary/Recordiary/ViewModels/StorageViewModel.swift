//
//  StorageViewModel.swift
//  Recordiary
//
//  Created by 김민아 on 11/20/24.
//


import Combine

class StorageViewModel: ObservableObject {
    @Published var items: [Furniture] = [
        Furniture(name: "의자", date: "2023-11-18"),
        Furniture(name: "테이블", date: "2023-11-10"),
        Furniture(name: "소파", date: "2023-11-05")
    ]
    
    @Published var selectedFurniture: Furniture? = nil // 선택된 가구
    @Published var showDetails: Bool = false           // 상세 정보 표시 여부

    // 아이템 추가
    func addItem(_ item: Furniture) {
        items.append(item)
    }

    // 아이템 삭제
    func deleteItem(_ item: Furniture) {
        items.removeAll { $0.id == item.id }
    }

    // 가구 선택
    func selectFurniture(_ furniture: Furniture) {
        selectedFurniture = furniture
        showDetails = true
    }

    // 상세 화면에서 리스트로 돌아가기
    func backToList() {
        selectedFurniture = nil
        showDetails = false
    }
}
