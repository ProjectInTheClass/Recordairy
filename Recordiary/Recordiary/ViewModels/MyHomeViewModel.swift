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
    @Published var currentDiary: DiaryEntry? = nil  // 생성 중인 일기 객체
    @Published var isPlaying = false  // 재생 상태

    private let recordingManager = RecordingManager()

    init() {
        recordingManager.onPlaybackFinished = { [weak self] in
            DispatchQueue.main.async {
                self?.isPlaying = false  // 재생 상태 업데이트
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
    private func createDiary(with audioURL: URL) async {
        // 이전에 남아있을 수도 있는 일기 객체를 UI에 보여주지 않기 위해 치워야 합니다.
        self.currentDiary = nil
        do {
            let audioData = try Data(contentsOf: audioURL)
            let result = await apiClient.postDiary(
                userId: "90ed0a4a-5b48-496d-844b-64f4b29c2b3b",
                isPrivate: false, audioFile: audioData)
            switch result {
            case .success(let diaryId):
                print("Diary uploaded successfully with ID: \(diaryId)")
                Task {
                    for _ in 1...3 {
                        try await Task.sleep(nanoseconds: 7_000_000_000)  // wait for 7 seconds
                        let diaryModel = try await apiClient.getDiary(
                            userId: BASE_USER_ID, diaryId: diaryId
                        ).get()
                        let diaryEntry = toDiaryEntry(diaryModel: diaryModel)

                        if !diaryEntry.keyWord.isEmpty {
                            print("Summary update complete for \(diaryId)")
                            await MainActor.run {
                                self.currentDiary = diaryEntry
                            }
                            break
                        }
                    }
                }
            case .failure(let error):
                print("Failed to upload diary: \(error.localizedDescription)")
            }
        } catch {
            print("Failed to load audio file: \(error.localizedDescription)")
        }
    }
}
