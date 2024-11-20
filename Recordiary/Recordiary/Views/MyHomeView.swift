//
//  MyHomeView.swift
//  Recordiary
//
//  Created by 김민아 on 11/5/24.
//

import SwiftUI

struct MyHomeView: View {
    @StateObject private var viewModel = LibraryViewModel() // LibraryViewModel 사용
    @State private var isLibrarySheetPresented = false // 모달 시트 상태

    var body: some View {
        ZStack {
            Color(hex: "#FFF8E1").ignoresSafeArea() // 전체 배경색

            // 하단 중앙에 녹음 버튼
            VStack {
                Spacer()

                Button(action: {
                    viewModel.toggleRecording() // 녹음 상태 토글
                }) {
                    Image(viewModel.isRecording ? "radiobutton-recording" : "radiobutton-enabled")
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
                        LibraryModalContent(isPresented: $isLibrarySheetPresented, viewModel: viewModel) // 라이브러리 콘텐츠 전달
                    }
                }

                // 두 번째 버튼 - "tray"
                Button(action: {
                    print("Tray button tapped")
                }) {
                    Image(systemName: "tray")
                        .font(.system(size: 24))
                        .frame(width: 56, height: 56)
                        .background(Color.white)
                        .cornerRadius(21) // 둥근 모서리
                        .shadow(color: Color(hex: "#6DAFCF"), radius: 0, x: 0, y: 4) // 그림자 설정
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
