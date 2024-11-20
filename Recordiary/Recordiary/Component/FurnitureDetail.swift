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

    var body: some View {
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
                    print("재생 버튼 클릭")
                }) {
                    ZStack {
                        Circle() // 동그란 버튼
                            .fill(Color(hex: "#6DAFCF"))
                            .frame(width: 56, height: 56)
                        Image(systemName: "play.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                }
            }
            // 감정 추출 결과, 키워드 요약, 텍스트
            VStack(alignment: .leading, spacing: 8) {
                Text("감정 추출 결과: 행복함")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                Text("키워드 요약: 즐거움, 웃음, 여행")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                Text("텍스트: 오늘은 정말 즐거운 하루였다.")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
            }
        }
        .padding(16) // 모달 내 여백만 추가
    }
}
