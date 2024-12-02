import SwiftUI

// 감정 및 DiaryEntry 모델 정의
enum Emotion: String, Codable, CaseIterable {
    case anger = "화남"
    case sadness = "슬픔"
    case happiness = "행복"
    case neutral = "짜증"

    var color: Color {
        switch self {
        case .anger: return Color(hex: "#E57373")
        case .sadness: return Color(hex: "#A68DBF")
        case .happiness: return Color(hex: "#F2CD00")
        case .neutral: return Color(hex: "#81C784")
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
    @State private var entries: [DiaryEntry] = [
        DiaryEntry(
            date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
            emotion: .happiness,
            audioFileURL: URL(string: "dummy1")!,
            transcribedText: "오늘은 정말 행복한 날이었다!"
        ),
        DiaryEntry(
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            emotion: .sadness,
            audioFileURL: URL(string: "dummy2")!,
            transcribedText: "오늘은 조금 슬펐던 하루였다."
        ),
        DiaryEntry(
            date: Calendar.current.date(byAdding: .day, value: 0, to: Date())!,
            emotion: .neutral,
            audioFileURL: URL(string: "dummy3")!,
            transcribedText: "그냥 평범한 하루였어."
        ),
        DiaryEntry(
            date: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
            emotion: .anger,
            audioFileURL: URL(string: "dummy4")!,
            transcribedText: "오늘은 정말 화나는 일이 있었다!"
        )
    ]
    @State private var selectedDate: Date?
    @State private var currentMonth: Date = Date()
    @State private var showCustomModal: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            calendarHeader
                .padding(.top)

            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                .overlay(
                    VStack(spacing: 16) {
                        daysOfWeekHeader
                        calendarGrid
                            .padding(.horizontal)
                    }
                    .padding(.vertical)
                )
                .padding(.horizontal)

            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                .overlay(
                    emotionStats
                        .padding()
                )
                .padding(.horizontal)

            Spacer()
        }
        .background(Color(hex: "#FFF8E1").ignoresSafeArea())
        .sheet(isPresented: $showCustomModal) {
            if let date = selectedDate {
                CustomModal {
                    modalContent(for: date)
                }
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

    // 요일 헤더
    private var daysOfWeekHeader: some View {
        let daysOfWeek = ["일", "월", "화", "수", "목", "금", "토"]

        return HStack {
            ForEach(daysOfWeek, id: \.self) { day in
                Text(day)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.gray)
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
                    showCustomModal = true
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

    // 감정 통계 (3D 원형 그래프 및 감정 정보 포함)
    private var emotionStats: some View {
        let statistics = emotionStatistics(for: currentMonth)
        let totalEntries = entries(for: currentMonth).count

        return HStack(alignment: .top) {
            // 감정별 정보
            VStack(alignment: .leading, spacing: 8) {
                Text("이번달 일기 수: \(totalEntries)")
                    .font(.headline)
                    .padding(.bottom, 8)

                ForEach(Emotion.allCases, id: \.self) { emotion in
                    let count = Int(statistics[emotion] ?? 0)
                    let percentage = totalEntries > 0 ? (statistics[emotion] ?? 0) : 0
                    HStack {
                        Circle()
                            .fill(emotion.color)
                            .frame(width: 12, height: 12)
                        Text("\(emotion.rawValue) 총 \(count)일 (\(String(format: "%.0f", percentage))%)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // 원형 그래프
            PieChartView(statistics: statistics)
                .frame(width: 150, height: 150)
        }
        .padding()
    }


    // 모달 내용
    private func modalContent(for date: Date) -> some View {
        VStack {
            if let entry = entries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
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
    }

    // 날짜별 색상 반환
    private func colorForDate(_ date: Date) -> Color {
        if let entry = entries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            return entry.emotion.color.opacity(0.3)
        }
        return Color.clear
    }

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

// 3D 원형 그래프 뷰
struct PieChartView: View {
    let statistics: [Emotion: Double]

    var body: some View {
        GeometryReader { geometry in
            let total = statistics.values.reduce(0, +)
            let angles = statistics.map { emotion, value in
                (emotion, Angle.degrees(value / total * 360))
            }

            ZStack {
                ForEach(angles.indices, id: \.self) { index in
                    let startAngle = angles.prefix(index).map(\.1).reduce(Angle.degrees(0), +)
                    let endAngle = startAngle + angles[index].1
                    PieSlice(startAngle: startAngle, endAngle: endAngle)
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [angles[index].0.color.opacity(0.8), angles[index].0.color]),
                                center: .center,
                                startRadius: 0,
                                endRadius: geometry.size.width / 2
                            )
                        )
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 2, y: 2)
                }
            }
        }
    }
}

struct PieSlice: Shape {
    var startAngle: Angle
    var endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        return path
    }
}

