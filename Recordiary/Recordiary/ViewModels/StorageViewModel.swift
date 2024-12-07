//
//  StorageViewModel.swift
//  Recordiary
//
//  Created by 김민아 on 11/20/24.
//


import Combine

class StorageViewModel: ObservableObject {
    @Published var items: [DiaryConnectedFurniture] = [] // is_set이 false인 연결된 가구들
    @Published var selectedFurniture: DiaryConnectedFurniture? = nil // 선택된 가구
    @Published var showDetails: Bool = false // 상세 정보 표시 여부
    
    // 초기화: 더미 데이터에서 is_set == false인 항목만 가져오기
    init() {
        self.items = diaryConnectedFurnitureDummyData.filter { !$0.is_set }
    }

    // 가구 추가
    func addItem(_ item: DiaryConnectedFurniture) {
        items.append(item)
    }

    // 가구 선택
    func selectFurniture(_ furniture: DiaryConnectedFurniture) {
        selectedFurniture = furniture
        showDetails = true
    }

    // 상세 화면에서 리스트로 돌아가기
    func backToList() {
        selectedFurniture = nil
        showDetails = false
    }

    // 가구 삭제
    func deleteItem(_ item: DiaryConnectedFurniture) {
        items.removeAll { $0.id == item.id }
    }
    
    func updateIsSetToTrue(_ item: DiaryConnectedFurniture) {
        // `is_set`을 true로 업데이트
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].is_set = true
            // 보관함에서 제거
            items.remove(at: index)
        }
    }
}
