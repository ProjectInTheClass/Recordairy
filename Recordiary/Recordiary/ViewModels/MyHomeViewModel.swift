//
//  MyHomeViewModel.swift
//  Recordiary
//
//  Created by 김민아 on 11/5/24.
//


import Foundation

class MyHomeViewModel: ObservableObject {
    @Published var isRecording = false
    private let recordingManager = RecordingManager()  // 녹음 관리 객체
    
    func toggleRecording() {
        if isRecording {
            recordingManager.stopRecording()
        } else {
            recordingManager.startRecording()
        }
        isRecording.toggle()
    }
}
