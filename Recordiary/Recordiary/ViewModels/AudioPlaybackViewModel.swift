//
//  AudioPlaybackViewModel.swift
//  Recordiary
//
//  Created by 김민아 on 12/7/24.
//

import AVFoundation

class AudioPlaybackViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate
{
    @Published var isPlaying = false
    private var audioPlayer: AVAudioPlayer?

    // 음성 파일 재생
    func playAudio(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                do {
                    let player = try AVAudioPlayer(data: data!)
                    self.audioPlayer = player
                    player.delegate = self
                    player.prepareToPlay()
                    player.volume = 1.0
                    player.play()
                    self.isPlaying = true
                } catch {
                    self.isPlaying = false
                    print(
                        "Error creating AVAudioPlayer: \(error)"
                    )
                }
            }
        }.resume()

    }

    // 음성 파일 중지
    func stopAudio() {
        audioPlayer?.pause()
        isPlaying = false
    }

    // AVAudioPlayerDelegate: 재생 완료 콜백
    func audioPlayerDidFinishPlaying(
        _ player: AVAudioPlayer, successfully flag: Bool
    ) {
        isPlaying = false
    }
}
