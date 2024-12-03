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

// Date를 Identifiable로 확장
extension Date: Identifiable {
    public var id: TimeInterval {
        self.timeIntervalSince1970
    }
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
    @State private var selectedDate: Date? = nil
    @State private var currentMonth: Date = Date()

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
        .sheet(item: $selectedDate) { date in
            CustomModal {
                modalContent(for: date)
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
            VStack(alignment: .leading, spacing: 8) {
                Text("이번달 일기 수: \(totalEntries)")
                    .font(.headline)
                    .padding(.bottom, 8)

                ForEach(statistics, id: \.emotion) { stat in
                    HStack {
                        Circle()
                            .fill(stat.emotion.color)
                            .frame(width: 12, height: 12)
                        Text("\(stat.emotion.rawValue) 총 \(stat.count)일 (\(String(format: "%.0f", stat.percentage))%)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            PieChartView(statistics: statistics.reduce(into: [:]) { $0[$1.emotion] = $1.percentage })
                .frame(width: 150, height: 150)
        }
        .padding()
    }
    
    private func modalContent(for date: Date) -> some View {
        GeometryReader { geometry in
            VStack(spacing: 16) {
                // 상단 닫기 버튼
                HStack {
                    Button(action: {
                        selectedDate = nil // 모달 닫기
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "#E0E0E0"))
                                .frame(width: 44, height: 44)
                            Image(systemName: "xmark")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 16) // 닫기 버튼 기준 정렬
                .padding(.top, geometry.safeAreaInsets.top + 8) // 안전 영역 추가

                if let entry = entries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
                    VStack(alignment: .leading, spacing: 16) {
                        // 가구 사진 및 날짜 정보
                        HStack(spacing: 16) {
                            RoundedRectangle(cornerRadius: 21)
                                .fill(Color(hex: "#E0E0E0"))
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.gray)
                                        .padding(8)
                                )

                            VStack(alignment: .leading, spacing: 4) {
                                Text("가구 이름")
                                    .font(.system(size: 18, weight: .semibold))
                                Text(date, formatter: dateFormatter)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            // 재생 버튼
                            Button(action: {
                                print("녹음 재생 버튼 클릭")
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: "#6DAFCF"))
                                        .frame(width: 56, height: 56)
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(.horizontal, 16) // 닫기 버튼과 정렬 맞춤

                        Divider()
                            .padding(.vertical, 8)

                        // 감정 추출 결과
                    
                        VStack(alignment: .leading, spacing: 8) {
                            Text("감정 추출 결과")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "#6DAFCF"))

                            Text(entry.emotion.rawValue)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(entry.emotion.color)
                                .cornerRadius(20) // 둥글게 변경
                        }
                        .padding(.horizontal, 16) // 정렬 유지

                        Divider()
                            .padding(.vertical, 8)

                        // 키워드 요약
                        VStack(alignment: .leading, spacing: 8) {
                            Text("키워드 요약")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "#6DAFCF"))

                            HStack(spacing: 8) {
                                Text("키워드 1")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color(hex: "#6DAFCF"))
                                    .cornerRadius(20) // 둥글게 변경

                                Text("키워드 2")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color(hex: "#6DAFCF"))
                                    .cornerRadius(20) // 둥글게 변경
                            }
                        }
                        .padding(.horizontal, 16) // 정렬 유지

                        Divider()
                            .padding(.vertical, 8)

                        // 텍스트
                        VStack(alignment: .leading, spacing: 8) {
                            Text("텍스트")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "#6DAFCF"))

                            Text(entry.transcribedText)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, 16) // 닫기 버튼과 정렬 맞춤
                    }
                    .frame(maxWidth: .infinity, alignment: .leading) // 전체 왼쪽 정렬
                } else {
                    // 일기가 없는 경우
                    VStack(spacing: 16) {
                        Text("해당 날짜에 녹음된 일기가 없습니다.")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)

                        Spacer() // 고정 높이를 유지하기 위해 추가
                    }
                    .frame(maxHeight: 300) // 최소 높이 설정
                }

                Spacer()
            }
            .padding(.vertical, 16)
            .background(Color(hex: "#FFFDF7").ignoresSafeArea()) // 배경색
            .presentationDetents([.medium, .large]) // 시트 높이 설정
            .presentationDragIndicator(.hidden) // 드래그 인디케이터 숨기기
        }
    }


  /*  private func modalContent(for date: Date) -> some View {
        VStack(spacing: 16) {
            // 닫기 버튼
            HStack {
                Button(action: {
                    selectedDate = nil // 모달 닫기
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#E0E0E0"))
                            .frame(width: 44, height: 44)
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                }
                Spacer() // 닫기 버튼 왼쪽 고정
            }
            .padding(.horizontal)
            .padding(.top, 8) // 경계 아래 간격

            if let entry = entries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
                VStack(spacing: 16) {
                    // 상단 이미지와 날짜 정보
                    HStack(spacing: 16) {
                        RoundedRectangle(cornerRadius: 21)
                            .fill(Color(hex: "#E0E0E0"))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.gray)
                                    .padding(8)
                            )

                        VStack(alignment: .leading, spacing: 4) {
                            Text("가구 이름")
                                .font(.system(size: 18, weight: .semibold))
                            Text(date, formatter: dateFormatter)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        // 재생 버튼
                        Button(action: {
                            print("녹음 재생 버튼 클릭")
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "#6DAFCF"))
                                    .frame(width: 56, height: 56)
                                Image(systemName: "play.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Divider()
                        .padding(.vertical, 8)

                    // 감정 추출 결과
                    VStack(alignment: .leading, spacing: 8) {
                        Text("감정 추출 결과")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "#6DAFCF"))

                        Text(entry.emotion.rawValue)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(entry.emotion.color)
                            .cornerRadius(8)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Divider()
                        .padding(.vertical, 8)

                    // 키워드 요약
                    VStack(alignment: .leading, spacing: 8) {
                        Text("키워드 요약")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "#6DAFCF"))

                        HStack(spacing: 8) {
                            Text("키워드 1")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color(hex: "#6DAFCF"))
                                .cornerRadius(8)

                            Text("키워드 2")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color(hex: "#6DAFCF"))
                                .cornerRadius(8)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Divider()
                        .padding(.vertical, 8)

                    // 텍스트
                    VStack(alignment: .leading, spacing: 8) {
                        Text("텍스트")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "#6DAFCF"))

                        Text(entry.transcribedText)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                // 일기가 없는 경우
                VStack(spacing: 16) {
                    Text("해당 날짜에 녹음된 일기가 없습니다.")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)

                    Spacer() // 고정 높이를 유지하기 위해 추가
                }
                .frame(maxHeight: 300) // 최소 높이 설정
            }

            Spacer()
        }
        .padding(16)
        .background(Color(hex: "#FFFDF7").ignoresSafeArea()) // 모달 배경색
        .presentationDetents([.medium, .large]) // 중형 및 대형 디텐트
        .presentationDragIndicator(.hidden) // 드래그 인디케이터 숨기기
    }*/

    private func colorForDate(_ date: Date) -> Color {
        if let entry = entries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            return entry.emotion.color.opacity(0.3)
        }
        return Color.clear
    }

    private func emotionStatistics(for month: Date) -> [(emotion: Emotion, count: Int, percentage: Double)] {
        let monthEntries = entries(for: month)
        let total = Double(monthEntries.count)

        var result: [(emotion: Emotion, count: Int, percentage: Double)] = []

        for emotion in Emotion.allCases {
            let count = monthEntries.filter { $0.emotion == emotion }.count
            let percentage = total > 0 ? (Double(count) / total) * 100 : 0
            result.append((emotion: emotion, count: count, percentage: percentage))
        }

        return result
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

            // 데이터가 없을 경우 처리
            if total == 0 {
                Text("데이터 없음")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(.gray)
                    .font(.headline)
            } else {
                let angles = calculateAngles(from: statistics, total: total)

                ZStack {
                    ForEach(angles.indices, id: \.self) { index in
                        let slice = angles[index]
                        PieSlice(startAngle: slice.start, endAngle: slice.end)
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [slice.emotion.color.opacity(0.8), slice.emotion.color]),
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

    private func calculateAngles(from statistics: [Emotion: Double], total: Double) -> [(emotion: Emotion, start: Angle, end: Angle)] {
        var angles: [(emotion: Emotion, start: Angle, end: Angle)] = []
        var currentAngle = Angle.degrees(0)

        for emotion in Emotion.allCases {
            let value = statistics[emotion] ?? 0
            let angle = Angle.degrees(value / total * 360)
            let startAngle = currentAngle
            let endAngle = currentAngle + angle
            angles.append((emotion, startAngle, endAngle))
            currentAngle = endAngle
        }

        return angles
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

