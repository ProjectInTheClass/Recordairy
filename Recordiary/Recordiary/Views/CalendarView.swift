import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: CalendarViewModel

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
        .sheet(item: $viewModel.selectedDiary) { diary in
            CustomModal {
                if let connectedFurniture = diary.connectedFurniture {
                    FurnitureDetailContent(
                        detailedFurniture: DiaryConnectedFurniture(
                            furniture: connectedFurniture,
                            diary: diary,
                            created_at: diary.created_at,
                            is_set: true,
                            is_vaild: true
                        )
                    )
                } else {
                    DiaryDetailContent(detailedDiary: diary)
                }
            }
        }
    }

    private var calendarHeader: some View {
        HStack {
            Button(action: {
                viewModel.updateMonth(by: -1)
            }) {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text("\(viewModel.currentMonth, formatter: monthFormatter)")
                .font(.headline)
            Button(action: {
                viewModel.populateEntries()
            }) {
                Image(systemName: "arrow.clockwise")
            }
            Spacer()
            Button(action: {
                viewModel.updateMonth(by: 1)
            }) {
                Image(systemName: "chevron.right")
            }
        }
        .padding(.horizontal)
    }

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

    private var calendarGrid: some View {
        let daysInMonth = Calendar.current.range(of: .day, in: .month, for: viewModel.currentMonth)!
        let firstDayOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: viewModel.currentMonth))!
        let firstWeekday = Calendar.current.component(.weekday, from: firstDayOfMonth)

        let columns = Array(repeating: GridItem(.flexible()), count: 7)
        return LazyVGrid(columns: columns, spacing: 10) {
            ForEach(0..<firstWeekday - 1, id: \.self) { _ in Text("") }

            ForEach(1...daysInMonth.count, id: \.self) { day in
                let date = Calendar.current.date(byAdding: .day, value: day - 1, to: firstDayOfMonth)!
                Button(action: {
                    viewModel.selectedDiary = viewModel.entries.first(where: { Calendar.current.isDate($0.created_at, inSameDayAs: date) })
                }) {
                    Text("\(day)")
                        .padding(8)
                        .background(viewModel.colorForDate(date))
                        .clipShape(Circle())
                        .foregroundColor(.black)
                }
            }
        }
        .padding(.top, 8)
    }

    private var emotionStats: some View {
        let statistics = viewModel.emotionStatistics()
        let totalEntries = viewModel.filteredEntries.count

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

    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
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

