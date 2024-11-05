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
            
            VStack {
                Spacer() // 녹음 버튼을 하단으로 밀기 위한 Spacer

                Button(action: {
                    viewModel.toggleRecording() // 녹음 상태 토글
                }) {
                    Image(viewModel.isRecording ? "radiobutton-recording" : "radiobutton-enabled") // 상태에 따른 이미지 변경
                        .resizable()
                        .frame(width: 100, height: 100) // 버튼 크기 설정
                }
                .padding(.bottom, 24) // 하단 여백 24px
            }
        }
    }
}
