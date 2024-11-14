import SwiftUI

struct CalendarView: View {
    @State private var selectedDate: Date?
    @State private var currentMonth: Date = Date()
    @State private var showAudioDiary: Bool = false

    private let colorCodedDates: [Date: Color] = [
        Calendar.current.date(from: DateComponents(year: 2024, month: 11, day: 1))!: .red,
        Calendar.current.date(from: DateComponents(year: 2024, month: 11, day: 15))!: .green,
        Calendar.current.date(from: DateComponents(year: 2024, month: 11, day: 20))!: .blue
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            calendarHeader
                .padding(.top)
            
            calendarGrid
                .padding(.horizontal)
                .background(RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2))
            
            Spacer()
            
            emotionStats
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(hex: "#FFF8E1"))
        }
        .background(Color(hex: "#FFF8E1").ignoresSafeArea())
        .sheet(isPresented: $showAudioDiary, onDismiss: {
            // 시트가 닫힐 때 상태 초기화
            selectedDate = nil
            showAudioDiary = false
        }) {
            if let selectedDate = selectedDate {
                AudioDiaryView(date: selectedDate)
                    .presentationDetents([.medium]) // 시트를 중간 높이까지만 표시
            }
        }
    }
    
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
                    showAudioDiary = true
                }) {
                    Text("\(day)")
                        .padding(8)
                        .background(colorCodedDates[date, default: Color.clear].opacity(0.3))
                        .clipShape(Circle())
                        .foregroundColor(.black)
                }
            }
        }
        .padding(.top, 8)
    }
    
    private var emotionStats: some View {
        VStack(alignment: .leading) {
            Text("나의 감정 통계")
                .font(.headline)
                .padding(.bottom, 10)
            Text("여기에 감정 통계를 표시할 수 있습니다.")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
    
    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
}

struct AudioDiaryView: View {
    var date: Date
    
    var body: some View {
        VStack {
            Text("Audio Diary for \(date, formatter: dateFormatter)")
                .font(.headline)
            Text("Play your audio diary here.")
                .padding()
            Button("Close") {}
        }
        .padding()
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}


