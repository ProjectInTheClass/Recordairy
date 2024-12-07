//
//  FurnitureDummyData.swift
//  Recordiary
//
//  Created by 김민아 on 12/3/24.
//


import SwiftUI
import Foundation

let furnitureDummyData = [
    Furniture(
        name: "wallpaper",
        display_name: "벽지",
        img: URL(string: "https://example.com/wallpaper.png")!,
        asset_link: URL(string: "https://example.com/wallpaper_3d.glb")!,
        category: .wall,
        quantity: 2
    ),
    Furniture(
        name: "rug",
        display_name: "카펫",
        img: URL(string: "https://example.com/rug.png")!,
        asset_link: URL(string: "https://example.com/rug_3d.glb")!,
        category: .floorRug,
        quantity: 1
    ),
    Furniture(
        name: "sofa",
        display_name: "소파",
        img: URL(string: "https://example.com/sofa.png")!,
        asset_link: URL(string: "https://example.com/sofa_3d.glb")!,
        category: .generalFurniture,
        quantity: 0 // 미보유
    ),
    Furniture(
        name: "table",
        display_name: "테이블",
        img: URL(string: "https://example.com/table.png")!,
        asset_link: URL(string: "https://example.com/table_3d.glb")!,
        category: .supportingFurniture,
        quantity: 1
    ),
    Furniture(
        name: "vase",
        display_name: "꽃병",
        img: URL(string: "https://example.com/vase.png")!,
        asset_link: URL(string: "https://example.com/vase_3d.glb")!,
        category: .smallItem,
        quantity: 3
    )
]

let diaryDummyData: [DiaryEntry] = [
//    DiaryEntry(
//        user_id: 1,
//        created_at: Date(), // 오늘 날짜
//        local_date: dateFormatter.string(from: Date()), // Medium 스타일로 포맷팅된 날짜
//        emotion: .happiness,
//        audio_link: URL(string: "https://example.com/audio1.mp3")!,
//        keyWord: "행복",
//        transcribedText: "오늘은 정말 행복한 하루였다.",
//        is_private: true,
//        connectedFurniture: furnitureDummyData[0]
//    ),
    DiaryEntry(
        user_id: 2,
        created_at: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, // 어제
        local_date: dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: -1, to: Date())!),
        emotion: .neutral,
        audio_link: URL(string: "https://example.com/audio2.mp3")!,
        keyWord: "보통",
        transcribedText: "그저 그런 하루였다.",
        is_private: false,
        connectedFurniture: furnitureDummyData[1]
    ),
    DiaryEntry(
        user_id: 3,
        created_at: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, // 2일 전
        local_date: dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: -2, to: Date())!),
        emotion: .sadness,
        audio_link: URL(string: "https://example.com/audio3.mp3")!,
        keyWord: "슬픔",
        transcribedText: "슬픈 하루였지만 희망을 잃지 않았다.",
        is_private: true,
        connectedFurniture: nil
    ),
    DiaryEntry(
        user_id: 4,
        created_at: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, // 3일 전
        local_date: dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: -3, to: Date())!),
        emotion: .anger,
        audio_link: URL(string: "https://example.com/audio4.mp3")!,
        keyWord: "화남",
        transcribedText: "오늘은 정말 화나는 일이 많았다.",
        is_private: false,
        connectedFurniture: nil
    )
]

let diaryConnectedFurnitureDummyData: [DiaryConnectedFurniture] = [
//    DiaryConnectedFurniture(
//        furniture: furnitureDummyData[0], // 벽지
//        diary: diaryDummyData[0],
//        created_at: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!, // 1시간 전
//        is_set: true,
//        is_vaild: true,
//        position: (x: 1, y: 1),
//        direction: 1
//    ),
    DiaryConnectedFurniture(
        furniture: furnitureDummyData[1], // 카펫
        diary: diaryDummyData[0],
        created_at: Calendar.current.date(byAdding: .hour, value: -3, to: Date())!, // 3시간 전
        is_set: false,
        is_vaild: true,
        position: nil,
        direction: nil
    ),
    DiaryConnectedFurniture(
        furniture: furnitureDummyData[2], // 소파
        diary: diaryDummyData[1],
        created_at: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, // 하루 전
        is_set: true,
        is_vaild: false,
        position: (x: 2, y: 3),
        direction: 3
    ),
    DiaryConnectedFurniture(
        furniture: furnitureDummyData[4], // 꽃병
        diary: diaryDummyData[2],
        created_at: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, // 2일 전
        is_set: true,
        is_vaild: true,
        position: (x: 4, y: 5),
        direction: 2
    )
]

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium // Medium 스타일로 날짜 형식 지정
    formatter.locale = Locale(identifier: "ko_KR") // 한국 로케일
    return formatter
}()
