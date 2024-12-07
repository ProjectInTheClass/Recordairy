//
//  RecordView.swift
//  Recordiary
//
//  Created by 김민아 on 12/6/24.
//

import SwiftUI

struct FirstRectangleView: View {
    @Binding var isPlaying: Bool
    @Binding var currentDiary: DiaryEntry?
    var onNext: () -> Void
    var onPlayPause: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack{
                        titleWithSeparator("음성 듣기")
                        Button(action: onNext) {
                            HStack {
                                Text("다음")
                                    .font(.system(size: 16, weight: .semibold))
                                Image(systemName: "arrow.right")
                            }
                            .foregroundColor(Color(hex: "#999999"))
                        }
                    }
                    Button(action: onPlayPause) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "#6DAFCF"))
                                .frame(width: 56, height: 56)
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                        }
                    }

                    if let diary = currentDiary {
                        titleWithSeparator("감정 추출 결과")
                        Text(diary.emotion.rawValue)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 67, height: 34)
                            .background(
                                RoundedRectangle(cornerRadius: 40)
                                    .fill(diary.emotion.color)
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)

                        titleWithSeparator("키워드 요약")
                        TextEditor(text: Binding(
                            get: { diary.keyWord },
                            set: { currentDiary?.keyWord = $0 }
                        ))
                        .frame(height: 80)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))

                        titleWithSeparator("텍스트")
                        TextEditor(text: Binding(
                            get: { diary.transcribedText },
                            set: { currentDiary?.transcribedText = $0 }
                        ))
                        .frame(height: 120)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
                    }
                }
                .padding(16)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 21)
                .fill(Color(hex: "#FFFDF7"))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 2, y: 2)
        )
        .frame(width: 327, height: 381)
        .offset(y: -25)
    }

    private func titleWithSeparator(_ title: String) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(hex: "#6DAFCF"))

            Rectangle()
                .fill(Color(hex: "#6DAFCF"))
                .frame(height: 0.33)
                .padding(.top, 2)
        }
    }
}


struct SecondRectangleView: View {
    @ObservedObject var libraryViewModel: LibraryViewModel
    @Binding var selectedFurnitureIndex: Int
    var onBack: () -> Void
    var onPlacement: (Furniture) -> Void
    var onStore: (Furniture) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 상단 "이전" 버튼
            HStack {
                Button(action: onBack) {
                    HStack {
                        Image(systemName: "arrow.left")
                        Text("이전")
                    }
                    .foregroundColor(Color(hex: "#999999"))
                }
                Spacer()
            }
            .padding(.top, 16)
            .padding(.horizontal, 16)

            // 캐러셀 형식 가구 카드
                TabView(selection: $selectedFurnitureIndex) { // 바인딩
                    ForEach(libraryViewModel.ownedFurnitures.indices, id: \.self) { index in
                        furnitureCard(for: libraryViewModel.ownedFurnitures[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: 279)

            // 하단 버튼 영역
            HStack {
                // 투명한 네모
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.clear) // 투명 네모
                    .frame(width: 87, height: 34)

                Spacer()

                // "배치하기" 버튼
                Button(action: {
                    let selectedFurniture = libraryViewModel.ownedFurnitures[selectedFurnitureIndex]
                    onPlacement(selectedFurniture)
                }) {
                    Text("배치하기")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 87, height: 34)
                        .background(Color(hex: "#6DAFCF"))
                        .cornerRadius(12)
                }

                Spacer()

                // "보관하기" 버튼
                Button(action: {
                    let selectedFurniture = libraryViewModel.ownedFurnitures[selectedFurnitureIndex]
                    onStore(selectedFurniture)
                }) {
                    Text("보관하기")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 87, height: 34)
                        .background(Color(hex: "#E0E0E0"))
                        .cornerRadius(12)
                }

            }
            .padding(.bottom, 16)
            .padding(.horizontal, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 21)
                .fill(Color(hex: "#FFFDF7"))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 2, y: 2)
        )
        .frame(width: 327, height: 381)
        .offset(y: -25)
    }

    private func furnitureCard(for furniture: Furniture) -> some View {
        VStack(alignment: .center, spacing: 8) {
            RoundedRectangle(cornerRadius: 21)
                .fill(Color(hex: "#E0E0E0"))
                .frame(width: 237, height: 183)
                .overlay(
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .padding(5)
                        .foregroundColor(.gray)
                )

            Text(furniture.display_name)
                .font(.system(size: 16, weight: .semibold))

            Text("보유 개수: \(furniture.quantity)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
        }
        .frame(width: 269, height: 279)
        .background(
            RoundedRectangle(cornerRadius: 21)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 1, y: 1)
        )
    }
}
