//
//  MyHomeView.swift
//  Recordiary
//
//  Created by 김민아 on 11/5/24.
//

import SwiftUI

struct MyHomeView: View {
    @StateObject private var viewModel = LibraryViewModel() // LibraryViewModel 사용

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
                    viewModel.isLibrarySheetPresented = true // 모달 열기
                }) {
                    Image(systemName: "cart")
                        .font(.system(size: 24))
                        .frame(width: 56, height: 56)
                        .background(Color.white)
                        .cornerRadius(21) // 둥근 모서리
                        .shadow(color: Color(hex: "#6DAFCF"), radius: 0, x: 0, y: 4) // 그림자 설정
                }
                .sheet(isPresented: $viewModel.isLibrarySheetPresented) {
                    LibraryModalView(viewModel: viewModel) // LibraryModalView 사용
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

struct LibraryModalView: View {
    @ObservedObject var viewModel: LibraryViewModel // ViewModel 참조

    let columns = [GridItem(.adaptive(minimum: 100))] // 그리드 레이아웃

    var body: some View {
        VStack(spacing: 16) {
            // 상단 그랩바
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color(hex: "#E0E0E0"))
                .frame(width: 39, height: 5)
                .padding(.top, 8)

            // 검색창과 닫기 버튼
            HStack {
                Button(action: {
                    viewModel.isLibrarySheetPresented = false // 모달 닫기
                }) {
                    Image(systemName: "xmark")
                        .font(.title)
                        .foregroundColor(.red)
                }
                Spacer()
                TextField("검색어를 입력하세요", text: $viewModel.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.leading, 8)
            }
            .padding()

            // 가구 정보 그리드
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.filteredItems, id: \.self) { item in
                        Text(item)
                            .frame(maxWidth: .infinity, minHeight: 100)
                            .background(Color(hex: "#E0E0E0"))
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
        }
        .background(Color(hex: "#FFFDF7").ignoresSafeArea()) // 모달 배경색
        .presentationDetents([.medium]) // 중형 디텐트 설정
    }
}
