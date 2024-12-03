//
//  FurnitureDetail.swift
//  Recordiary
//
//  Created by 김민아 on 11/20/24.
//

import SwiftUI

struct Furniture: Identifiable {
    let id = UUID() // 고유 ID
    let name: String
    let date: String
}

struct FurnitureDetailContent: View {
    let furniture: Furniture // 가구 정보
    @State private var isPlaying = false // 재생 상태 저장

    var body: some View {
        ScrollView { // 스크롤 가능한 영역
            VStack(alignment: .leading, spacing: 16) { // 전체 왼쪽 정렬
                // 가구 이미지와 정보
                HStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 21)
                        .fill(Color(hex: "#E0E0E0"))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.gray)
                                .padding(8)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(furniture.name)
                            .font(.system(size: 18, weight: .semibold))
                        Text(furniture.date)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    // 재생 버튼
                    Button(action: {
                        isPlaying.toggle() // 재생 상태 토글
                    }) {
                        ZStack {
                            Circle() // 동그란 버튼
                                .fill(Color(hex: "#6DAFCF"))
                                .frame(width: 56, height: 56)
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill") // 상태에 따라 아이콘 변경
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                        }
                    }
                }

                // 섹션
                SectionView(title: "감정 추출 결과", content: "행복함", hasContentBox: false, contentBoxStyle: .highlighted)
                SectionView(title: "키워드 요약", content: "즐거움, 웃음, 여행", hasContentBox: true, contentBoxStyle: .regular)
                SectionView(title: "텍스트", content: "오늘은 정말 즐거운 하루였다.", hasContentBox: true, contentBoxStyle: .regular)
            }
            .padding(16) // 모달 내 여백 추가
        }
    }
}

struct SectionView: View {
    let title: String
    let content: String
    let hasContentBox: Bool // 내용 박스 유무
    let contentBoxStyle: ContentBoxStyle // 내용 스타일

    enum ContentBoxStyle {
        case regular      // 일반 텍스트
        case highlighted  // 강조된 스타일
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 제목 박스
            VStack(alignment: .leading) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "#6DAFCF"))
                    .frame(maxWidth: .infinity, alignment: .leading) // 왼쪽 상단 정렬
            }
            .frame(height: 30) // 제목 박스 높이
            .background(
                Rectangle()
                    .fill(Color.clear) // 투명 배경
                    .frame(height: 30) // 구분선 높이
                    .overlay(
                        Rectangle()
                            .fill(Color(hex: "#6DAFCF")) // 구분선 색상
                            .frame(height: 0.33),
                        alignment: .bottom // 하단에만 구분선 추가
                    )
            )

            // 내용 텍스트
            switch contentBoxStyle {
            case .regular:
                if hasContentBox {
                    Text(content)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .padding() // 내용의 내부 여백
                        .background(
                            Rectangle() // 각진 네모 박스
                                .fill(Color.white) // 흰색 배경
                        )
                } else {
                    Text(content)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                }

            case .highlighted:
                Text(content)
                    .font(.system(size: 16, weight: .bold)) // 강조된 텍스트
                    .foregroundColor(.white) // 흰색 텍스트
                    .frame(width: 67, height: 34) // 고정 크기
                    .background(
                        RoundedRectangle(cornerRadius: 40) // 곡률 40
                            .fill(Color(hex: "#FFA726")) // 배경 색상
                    )
                    .frame(maxWidth: .infinity, alignment: .leading) // 왼쪽 정렬
            }
        }
    }
}

