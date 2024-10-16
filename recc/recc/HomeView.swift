//
//  HomeView.swift
//  recc
//
//  Created by 권동민 on 10/16/24.
//


import SwiftUI
import AVFoundation

struct HomeView: View {
    @State private var audioRecorder: AVAudioRecorder?
    @State private var isRecording = false
    @State private var currentDate = Date()

    var body: some View {
        ZStack {
            Image("homeBackground")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()

            VStack {
                Spacer()

                // 녹음 버튼
                Button(action: {
                    if isRecording {
                        stopRecording()
                    } else {
                        startRecording()
                    }
                }) {
                    Text(isRecording ? "녹음 중지" : "녹음 시작")
                        
                        .foregroundColor(isRecording ? .red : .blue)
                        .padding()
                        .background(Circle().fill(Color.white).shadow(radius: 5))
                }
                .padding(.bottom, 50)
                
                HStack {
                    Spacer()
                    Button(action: {
                        // 하트 버튼 클릭 시 동작
                    }) {
                        Image(systemName: "heart")
                            .font(.system(size: 40))
                            .foregroundColor(.purple)
                    }
                    .padding()
                }
            }
        }
    }

    // 녹음 시작 함수
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent(generateFileName(for: currentDate))
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            isRecording = true
        } catch {
            print("녹음에 실패했습니다.")
        }
    }

    // 녹음 중지 함수
    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false
    }

    // 날짜별 파일명을 생성하는 함수
    func generateFileName(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return "\(dateFormatter.string(from: date))-recording.m4a"
    }

    // 파일 저장 경로 함수
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
