//
//  MyHomeViewModel.swift
//  Recordiary
//
//  Created by 김민아 on 11/5/24.
//


import Foundation

let apiClient = APIClient()

class MyHomeViewModel: ObservableObject {
    @Published var isRecording = false
    @Published var currentDiary: DiaryEntry? = nil // 생성 중인 일기 객체
    @Published var isPlaying = false // 재생 상태

    private let recordingManager = RecordingManager()
    
    init() {
        recordingManager.onPlaybackFinished = { [weak self] in
            DispatchQueue.main.async {
                self?.isPlaying = false // 재생 상태 업데이트
            }
        }
    }

    /// 녹음 시작 및 종료
    func toggleRecording() async {
        if isRecording {
            if let audioURL = recordingManager.stopRecording() {
                await createDiary(with: audioURL)
            }
        } else {
            let success = recordingManager.startRecording()
            if !success {
                print("녹음을 시작하지 못했습니다.")
            }
        }
        isRecording.toggle()
    }
    
    func playOrPauseRecording() {
        if isPlaying {
            recordingManager.stopPlaying()
        } else {
            recordingManager.playRecording()
        }
        isPlaying.toggle()
    }

    /// 녹음 파일로 일기 객체를 생성.
    private func createDiary(with audioURL: URL) async  {
        var newDiary = DiaryEntry(
            id: UUID(),
            user_id: 1,
            created_at: Date(),
            local_date: dateFormatter.string(from: Date()),
            emotion: .neutral,
            audio_link: audioURL,
            keyWord: "기본 키워드",
            transcribedText: "기본 텍스트",
            is_private: false,
            connectedFurniture: nil
        )
        do {
            let audioData = try Data(contentsOf: newDiary.audio_link)
            let result = await apiClient.postDiary(userId: "90ed0a4a-5b48-496d-844b-64f4b29c2b3b", isPrivate: false, audioFile: audioData)
            switch result {
            case .success(let diaryId):
                print("Diary uploaded successfully with ID: \(diaryId)")
            case .failure(let error):
                print("Failed to upload diary: \(error.localizedDescription)")
            }
        } catch {
            print("Failed to load audio file: \(error.localizedDescription)")
        }

        //텍스트 업데이트
        //감정 업데이트
        
        currentDiary = newDiary
        print("새 일기 생성됨: \(newDiary)")
    }
}
