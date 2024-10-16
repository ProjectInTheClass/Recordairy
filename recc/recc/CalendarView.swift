//
//  CalendarView.swift
//  recc
//
//  Created by 권동민 on 10/16/24.
//


import SwiftUI
import AVFoundation

struct CalendarView: View {
    @State private var selectedDate = Date()
    @State private var recordings: [URL] = []
    @State private var audioPlayer: AVAudioPlayer?

    var body: some View {
        VStack {
            DatePicker("날짜 선택", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
                .onChange(of: selectedDate, perform: { date in
                    loadRecordings(for: date)
                })

            if recordings.isEmpty {
                Text("해당 날짜에 녹음된 파일이 없습니다.")
                    .padding()
            } else {
                List(recordings, id: \.self) { recording in
                    HStack {
                        Text(recording.lastPathComponent)
                        Spacer()
                        Button(action: {
                            playRecording(recording)
                        }) {
                            Image(systemName: "play.circle")
                                .font(.system(size: 24))
                        }
                    }
                }
            }
        }
        .onAppear {
            loadRecordings(for: selectedDate)
        }
    }

    // 선택된 날짜에 해당하는 녹음 파일 로드
    func loadRecordings(for date: Date) {
        let fileManager = FileManager.default
        let documentDirectory = getDocumentsDirectory()

        do {
            let allFiles = try fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: date)
            recordings = allFiles.filter { $0.lastPathComponent.contains(dateString) }
        } catch {
            print("파일을 로드하는 중 오류 발생: \(error)")
        }
    }

    // 파일 재생 함수
    func playRecording(_ url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("파일을 재생하는 중 오류 발생: \(error)")
        }
    }

    // 파일 저장 경로 함수
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}
