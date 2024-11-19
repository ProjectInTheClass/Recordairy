import SwiftUI

// 감정 및 DiaryEntry 모델 정의
enum Emotion: String, Codable, CaseIterable {
    case anger = "화남"
    case sadness = "우울함"
    case happiness = "행복함"
    case neutral = "평범함"

    var color: Color {
        switch self {
        case .anger: return .red
        case .sadness: return .blue
        case .happiness: return .yellow
        case .neutral: return .gray
        }
    }
}

struct DiaryEntry: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var emotion: Emotion
    var audioFileURL: URL
    var transcribedText: String
}

struct CalendarView: View {
    // 상태 관리
    @State private var entries: [DiaryEntry] = [] // 빈 배열로 초기화
    @State private var selectedDate: Date?
    @State private var currentMonth: Date = Date()
    @State private var showAudioPlayer: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            calendarHeader
                .padding(.top)

            calendarGrid
                .padding(.horizontal)
                .background(RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2))
            
            emotionStats
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(hex: "#FFF8E1"))

            Spacer()
        }
        .background(Color(hex: "#FFF8E1").ignoresSafeArea())
        .sheet(isPresented: $showAudioPlayer) {
            if let date = selectedDate {
                audioDiaryPlayerSheet
                    .presentationDetents([.medium]) // 중간 높이로 시트 표시
            }
        }
    }

    // 월 이동 버튼 및 현재 월 표시
    private var calendarHeader: some View {
        HStack {
            Button(action: {
                currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
            }) {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text("\(currentMonth, formatter: monthFormatter)")
                .font(.headline)
            Spacer()
            Button(action: {
                currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
            }) {
                Image(systemName: "chevron.right")
            }
        }
        .padding(.horizontal)
    }

    // 날짜 그리드
    private var calendarGrid: some View {
        let daysInMonth = Calendar.current.range(of: .day, in: .month, for: currentMonth)!
        let firstDayOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: currentMonth))!
        let firstWeekday = Calendar.current.component(.weekday, from: firstDayOfMonth)

        let columns = Array(repeating: GridItem(.flexible()), count: 7)
        return LazyVGrid(columns: columns, spacing: 10) {
            ForEach(0..<firstWeekday - 1, id: \.self) { _ in Text("") }

            ForEach(1...daysInMonth.count, id: \.self) { day in
                let date = Calendar.current.date(byAdding: .day, value: day - 1, to: firstDayOfMonth)!
                Button(action: {
                    selectedDate = date
                    showAudioPlayer = true
                }) {
                    Text("\(day)")
                        .padding(8)
                        .background(colorForDate(date))
                        .clipShape(Circle())
                        .foregroundColor(.black)
                }
            }
        }
        .padding(.top, 8)
    }

    // 감정 통계 섹션 (히스토그램)
    private var emotionStats: some View {
        let statistics = emotionStatistics(for: currentMonth)
        let emotions = Emotion.allCases

        return VStack(alignment: .leading) {
            Text("나의 감정 통계")
                .font(.headline)
                .padding(.bottom, 8)

            HStack(alignment: .bottom) {
                ForEach(emotions, id: \.self) { emotion in
                    VStack {
                        Text("\(Int(statistics[emotion] ?? 0))%")
                            .font(.caption)
                            .foregroundColor(.gray)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(emotion.color)
                            .frame(
                                width: 20,
                                height: CGFloat(statistics[emotion] ?? 0) * 2 // 비율에 따라 높이 조절
                            )
                        Text(emotion.rawValue)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    // 오디오 다이어리 재생 시트
    private var audioDiaryPlayerSheet: some View {
        VStack {
            if let date = selectedDate, let entry = entries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
                Text("일기 날짜: \(date, formatter: dateFormatter)")
                    .font(.headline)
                Text("분석된 감정: \(entry.emotion.rawValue)")
                    .font(.subheadline)
                Spacer()
                Text("오디오 재생 버튼이 여기에 추가될 수 있습니다.")
                    .foregroundColor(.gray)
            } else {
                Text("해당 날짜에 녹음된 일기가 없습니다.")
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }

    // 녹음 데이터 추가
    func addDiaryEntry(date: Date, audioURL: URL) {
        let transcribedText = transcribeAudio(from: audioURL) // 음성을 텍스트로 변환
        let emotion = analyzeEmotion(from: transcribedText) // 감정 분석
        let entry = DiaryEntry(date: date, emotion: emotion, audioFileURL: audioURL, transcribedText: transcribedText)
        entries.append(entry)
    }

    // 음성을 텍스트로 변환 (모의 함수)
    private func transcribeAudio(from url: URL) -> String {
        return "모의 텍스트 변환: 오늘은 정말 행복한 날이에요!"
    }

    // 텍스트에서 감정 분석
    private func analyzeEmotion(from text: String) -> Emotion {
        if text.contains("화") || text.contains("분노") {
            return .anger
        } else if text.contains("슬픔") || text.contains("우울") {
            return .sadness
        } else if text.contains("행복") || text.contains("기쁨") {
            return .happiness
        } else {
            return .neutral
        }
    }

    // 날짜별 색상 반환
    private func colorForDate(_ date: Date) -> Color {
        if let entry = entries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            return entry.emotion.color.opacity(0.3)
        }
        return Color.clear
    }

    // 감정 통계 계산
    private func emotionStatistics(for month: Date) -> [Emotion: Double] {
        let monthEntries = entries(for: month)
        let total = Double(monthEntries.count)
        var counts: [Emotion: Double] = [:]

        for emotion in Emotion.allCases {
            counts[emotion] = 0 // 기본값 0 설정
        }

        guard total > 0 else { return counts }

        for emotion in Emotion.allCases {
            counts[emotion] = Double(monthEntries.filter { $0.emotion == emotion }.count) / total * 100
        }
        return counts
    }

    // 특정 월의 일기 필터링
    private func entries(for month: Date) -> [DiaryEntry] {
        let calendar = Calendar.current
        return entries.filter { calendar.isDate($0.date, equalTo: month, toGranularity: .month) }
    }

    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}
