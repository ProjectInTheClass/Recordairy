//
//  RecordingManager.swift
//  Recordiary
//
//  Created by 김민아 on 11/5/24.
//


import AVFoundation

class RecordingManager: NSObject, AVAudioPlayerDelegate {
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?

    var onPlaybackFinished: (() -> Void)? // 재생 종료 시 호출될 클로저

    private let recordingSettings: [String: Any] = [
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        AVSampleRateKey: 12000,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]

    private var audioFileURL: URL {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("recording.m4a")
    }

    func startRecording() -> Bool {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)

            audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: recordingSettings)
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
            return true
        } catch {
            print("녹음 시작 실패: \(error.localizedDescription)")
            return false
        }
    }

    func stopRecording() -> URL? {
        audioRecorder?.stop()
        audioRecorder = nil
        return audioFileURL
    }

    func playRecording() {
        guard audioPlayer == nil || !audioPlayer!.isPlaying else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFileURL)
            audioPlayer?.delegate = self // 델리게이트 설정
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("녹음 파일 재생 실패: \(error.localizedDescription)")
        }
    }

    func stopPlaying() {
        audioPlayer?.stop()
        audioPlayer = nil
    }

    func isPlaying() -> Bool {
        return audioPlayer?.isPlaying ?? false
    }

    // AVAudioPlayerDelegate: 재생 완료 시 호출
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onPlaybackFinished?() // 클로저 호출
    }
}
