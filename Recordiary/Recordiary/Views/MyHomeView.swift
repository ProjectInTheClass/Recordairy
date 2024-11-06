//
//  MyHomeView.swift
//  Recordiary
//
//  Created by 김민아 on 11/5/24.
//

import SwiftUI

struct MyHomeView: View {
    @StateObject private var viewModel = MyHomeViewModel()

    var body: some View {
        ZStack {
            Color(hex: "#FFF8E1").ignoresSafeArea() // 전체 배경색

            // 하단 중앙에 녹음 버튼
            VStack {
                Spacer() // 녹음 버튼을 하단으로 밀기 위한 Spacer

                Button(action: {
                    viewModel.toggleRecording() // 녹음 상태 토글
                }) {
                    Image(viewModel.isRecording ? "radiobutton-recording" : "radiobutton-enabled")
                        .resizable()
                        .frame(width: 100, height: 100) // 버튼 크기 설정
                }
                .padding(.bottom, 24) // 하단 여백 24px
            }

            // 우측 상단에 수직으로 배치된 버튼들
            VStack(spacing: 16) {
                // 첫 번째 버튼 - "cart"
                Button(action: {
                    print("Cart button tapped")
                }) {
                    Image(systemName: "cart")
                        .font(.system(size: 24))
                        .frame(width: 56, height: 56)
                        .background(Color.white)
                        .cornerRadius(21) // 둥근 모서리
                        .shadow(color: Color(hex: "#6DAFCF"), radius: 0, x: 0, y: 4) // 그림자 설정
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
            .padding(.top, 16) // 네비게이션 바 아래 여백
            .padding(.trailing, 16) // 오른쪽 여백
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing) // 우측 상단 고정
        }
    }
}
