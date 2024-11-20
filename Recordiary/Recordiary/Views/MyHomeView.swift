//
//  MyHomeView.swift
//  Recordiary
//
//  Created by 김민아 on 11/5/24.
//

import SwiftUI

struct MyHomeView: View {
    @StateObject private var libraryViewModel = LibraryViewModel() // LibraryViewModel 사용
    @State private var isLibrarySheetPresented = false // 모달 시트 상태
    @State private var isStorageSheetPresented = false // 보관함 모달 상태

    var body: some View {
        ZStack {
            Color(hex: "#FFF8E1").ignoresSafeArea() // 전체 배경색

            // 하단 중앙에 녹음 버튼
            VStack {
                Spacer()

                Button(action: {
                    libraryViewModel.toggleRecording() // 녹음 상태 토글
                }) {
                    Image(libraryViewModel.isRecording ? "radiobutton-recording" : "radiobutton-enabled")
                        .resizable()
                        .frame(width: 100, height: 100) // 버튼 크기 설정
                }
                .padding(.bottom, 24)
            }

            // 우측 상단에 수직으로 배치된 버튼들
            VStack(spacing: 16) {
                // 첫 번째 버튼 - "cart" (라이브러리 모달 표시)
                Button(action: {
                    isLibrarySheetPresented = true // 모달 열기
                }) {
                    Image(systemName: "cart")
                        .font(.system(size: 24))
                        .frame(width: 56, height: 56)
                        .background(Color.white)
                        .cornerRadius(21) // 둥근 모서리
                        .shadow(color: Color(hex: "#6DAFCF"), radius: 0, x: 0, y: 4) // 그림자 설정
                }
                .sheet(isPresented: $isLibrarySheetPresented) {
                    CustomModal {
                        LibraryModalContent(isPresented: $isLibrarySheetPresented, viewModel: libraryViewModel) // 라이브러리 콘텐츠 전달
                    }
                }

                // 두 번째 버튼 - "tray"
                Button(action: {
                    isStorageSheetPresented = true
                }) {
                    Image(systemName: "tray")
                        .font(.system(size: 24))
                        .frame(width: 56, height: 56)
                        .background(Color.white)
                        .cornerRadius(21) // 둥근 모서리
                        .shadow(color: Color(hex: "#6DAFCF"), radius: 0, x: 0, y: 4) // 그림자 설정
                }
                .sheet(isPresented: $isStorageSheetPresented) {
                    CustomModal {
                        StorageModalContent(isPresented: $isStorageSheetPresented)
                    }
                }
            }
            .padding(.top, 16)
            .padding(.trailing, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing) // 우측 상단 고정
        }
    }
}

struct LibraryModalContent: View {
    @Binding var isPresented: Bool // 모달 상태 바인딩
    @ObservedObject var viewModel: LibraryViewModel // ViewModel 참조
    let columns = [GridItem(.flexible()), GridItem(.flexible())] // 한 줄에 두 개의 아이템

    var body: some View {
        VStack(spacing: 16) {
            // 검색창과 닫기 버튼
            HStack {
                // 닫기 버튼
                Button(action: {
                    isPresented = false // 모달 닫기
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#E0E0E0"))
                            .frame(width: 44, height: 44) // 닫기 버튼 크기
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                }

                Spacer()

                // 검색창
                TextField("검색어를 입력하세요", text: $viewModel.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.leading, 8)
            }
            .padding(.horizontal)

            // 필터 버튼
            HStack(spacing: 8) {
                Button(action: {
                    viewModel.filterMode = .all
                }) {
                    Text("전체")
                        .font(.headline)
                        .foregroundColor(viewModel.filterMode == .all ? .white : .black)
                        .frame(width: 70, height: 35)
                        .background(viewModel.filterMode == .all ? Color(hex: "#6DAFCF") : Color(hex: "#E0E0E0"))
                        .cornerRadius(8)
                }

                Button(action: {
                    viewModel.filterMode = .unowned
                }) {
                    Text("미보유")
                        .font(.headline)
                        .foregroundColor(viewModel.filterMode == .unowned ? .white : .black)
                        .frame(width: 70, height: 35)
                        .background(viewModel.filterMode == .unowned ? Color(hex: "#6DAFCF") : Color(hex: "#E0E0E0"))
                        .cornerRadius(8)
                }

                Spacer()
            }
            .padding(.horizontal)

            // 가구 정보 그리드
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.filteredItems, id: \.self) { item in
                        Text(item)
                            .frame(maxWidth: .infinity, minHeight: 100)
                            .background(
                                viewModel.isOwned(item: item) ? Color(hex: "#E0E0E0") : Color(hex: "#6DAFCF")
                            )
                            .cornerRadius(21)
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
                .padding()
            }
        }
        .background(Color(hex: "#FFFDF7").ignoresSafeArea()) // 모달 배경색
        .presentationDetents([.medium, .large]) // 중형 & 대형 디텐트 설정
        .presentationDragIndicator(.hidden) // 기본 드래그 인디케이터 숨기기
    }
}

struct StorageModalContent: View {
    @Binding var isPresented: Bool // 모달 상태 바인딩
    @StateObject private var viewModel = StorageViewModel() // ViewModel 사용

    var body: some View {
        VStack(spacing: 16) {
            // 상단 버튼
            HStack {
                if !viewModel.showDetails {
                    // 닫기 버튼
                    Button(action: {
                        isPresented = false // 모달 닫기
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "#E0E0E0"))
                                .frame(width: 44, height: 44)
                            Image(systemName: "xmark")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                        }
                    }
                }
                Spacer()
            }
            .padding(.horizontal)

            // 콘텐츠
            if viewModel.showDetails, let furniture = viewModel.selectedFurniture {
                // 가구 상세 정보
                StorageFurnitureDetailView(
                    furniture: furniture,
                    onBack: { viewModel.backToList() } // 리스트로 돌아가기
                )
            } else {
                // 가구 리스트
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.items) { item in
                            HStack(spacing: 16) {
                                Button(action: {
                                    viewModel.selectFurniture(item) // 가구 선택
                                }) {
                                    // 아이템 이미지 및 정보
                                    HStack(spacing: 16) {
                                        RoundedRectangle(cornerRadius: 21)
                                            .fill(Color(hex: "#E0E0E0"))
                                            .frame(width: 56, height: 56)
                                            .overlay(
                                                Image(systemName: "photo")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .foregroundColor(.gray)
                                                    .padding(8)
                                            )

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.name)
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundColor(.black)
                                            Text(item.date)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.gray)
                                        }

                                        Spacer()
                                    }
                                }

                                // 우측 추가 및 삭제 버튼 (동작 없음)
                                HStack(spacing: 8) {
                                    Button(action: {
                                        // 추가 버튼: 현재 동작 없음
                                    }) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 21)
                                                .fill(Color(hex: "#6DAFCF"))
                                                .frame(width: 56, height: 56)
                                            Image(systemName: "plus")
                                                .font(.system(size: 32))
                                                .foregroundColor(.white)
                                        }
                                    }

                                    Button(action: {
                                        // 삭제 버튼: 현재 동작 없음
                                    }) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 21)
                                                .fill(Color(hex: "#FF6F61"))
                                                .frame(width: 56, height: 56)
                                            Image(systemName: "trash")
                                                .font(.system(size: 32))
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color.white) // 아이템 배경
                            .cornerRadius(21)
                            .frame(height: 88)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct StorageFurnitureDetailView: View {
    let furniture: Furniture // 가구 정보
    let onBack: () -> Void   // 뒤로가기 동작

    var body: some View {
        VStack(spacing: 16) {
            // 상단 헤더: 이전 버튼
            HStack {
                Button(action: {
                    onBack() // 리스트로 돌아가기
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "#999999")) // 화살표 색
                        Text("이전")
                            .font(.system(size: 20, weight: .semibold)) // 글씨 크기 및 스타일
                            .foregroundColor(Color(hex: "#999999"))
                    }
                }
                Spacer()
            }
            .padding(.horizontal)

            // 상세 정보 콘텐츠
            FurnitureDetailContent(furniture: furniture)

            Spacer() // 하단 여백 추가로 상단 고정
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top) // 상단 정렬
        .background(Color(hex: "#FFFDF7").ignoresSafeArea()) // 배경 설정
    }
}
