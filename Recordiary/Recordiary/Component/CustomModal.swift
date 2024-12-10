//
//  CustomModal.swift
//  Recordiary
//
//  Created by 김민아 on 11/20/24.
//

import SwiftUI

struct CustomModal<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 16) {
            // 상단 그랩바
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color(hex: "#E0E0E0"))
                .frame(width: 39, height: 5)
                .padding(.top, 8)
            content
        }
        .background(Color(hex: "#FFFDF7").ignoresSafeArea()) // 공통 배경색
        .presentationDetents([.medium, .large]) // 중형 & 대형 디텐트
        .presentationDragIndicator(.hidden) // 기본 드래그 인디케이터 숨기기
    }
}

struct CustomModalLarge<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 16) {
            // 상단 그랩바
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color(hex: "#E0E0E0"))
                .frame(width: 39, height: 5)
                .padding(.top, 8)
            content
        }
        .background(Color(hex: "#FFFDF7").ignoresSafeArea()) // 공통 배경색
        .presentationDetents([.large]) // 중형 & 대형 디텐트
        .presentationDragIndicator(.hidden) // 기본 드래그 인디케이터 숨기기
    }
}
