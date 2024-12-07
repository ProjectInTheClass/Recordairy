//
//  AudioPlaybackViewModel.swift
//  Recordiary
//
//  Created by 김민아 on 12/7/24.
//


import AVFoundation

class AudioPlaybackViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying = false
    private var audioPlayer: AVAudioPlayer?

    // 음성 파일 재생
    func playAudio(from url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self // delegate 설정
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("Audio playback failed: \(error.localizedDescription)")
            isPlaying = false
        }
    }

    // 음성 파일 중지
    func stopAudio() {
        audioPlayer?.stop()
        isPlaying = false
    }

    // AVAudioPlayerDelegate: 재생 완료 콜백
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }
}
