//
//  Diary.swift
//  Recordiary
//
//  Created by RulerOfCakes on 12/4/24.
//

import Foundation

struct DiaryModel: Decodable {
    let id: Int
    let createdAt: Date
    let localDate: String
    let userId: String
    let audioLink: String
    let summary: String?
    let transcription: String?
    let emotion: String?
    let isPrivate: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case localDate = "local_date"
        case userId = "user_id"
        case audioLink = "audio_link"
        case summary
        case transcription
        case emotion
        case isPrivate = "is_private"
    }
}

func toDiaryEntry(diaryModel: DiaryModel) -> DiaryEntry {
    let audioLink = URL(string: diaryModel.audioLink)!
    let emotion = switch diaryModel.emotion ?? "neutral" {
    case "anger":
        Emotion.anger
    case "sadness":
        Emotion.sadness
    case "happiness":
        Emotion.happiness
    default:
        Emotion.neutral
    }
    return DiaryEntry(id: diaryModel.id, user_id: diaryModel.userId, created_at: diaryModel.createdAt, local_date: diaryModel.localDate, emotion: emotion, audio_link: audioLink, keyWord: diaryModel.summary ?? "", transcribedText: diaryModel.transcription ?? "", is_private: diaryModel.isPrivate)
}

struct CalendarEntryModel: Decodable {
    let createdAt: Date
    let diary: DiaryModel
    
    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case diary
    }
}

func toDiaryEntry(calendarEntry: CalendarEntryModel) -> DiaryEntry {
    return toDiaryEntry(diaryModel: calendarEntry.diary)
}
