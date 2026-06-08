import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @State private var displayedMonth = Date()

    private var monthFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                monthNavigation
                calendarGrid
                Spacer()
            }
            .navigationTitle("Calendar")
            .onAppear { viewModel.load() }
        }
    }

    private var monthNavigation: some View {
        HStack {
            Button(action: { changeMonth(-1) }) {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(monthFormatter.string(from: displayedMonth))
                .font(.headline)
            Spacer()
            Button(action: { changeMonth(1) }) {
                Image(systemName: "chevron.right")
            }
        }
        .padding()
    }

    private var calendarGrid: some View {
        let days = daysInMonth()
        let firstWeekday = firstWeekdayOfMonth()

        return VStack(spacing: 4) {
            HStack(spacing: 0) {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                ForEach(0..<firstWeekday, id: \.self) { _ in
                    Color.clear.frame(height: 40)
                }

                ForEach(days, id: \.self) { date in
                    dayCell(for: date)
                }
            }
            .padding(.horizontal)
        }
    }

    private func dayCell(for date: Date) -> some View {
        let day = Calendar.current.component(.day, from: date)
        let isPeriod = viewModel.isPeriodDay(date)
        let isPredicted = viewModel.isPredictedDay(date)
        let isToday = viewModel.isToday(date)

        return VStack(spacing: 2) {
            Text("\(day)")
                .font(.caption)
                .fontWeight(isToday ? .bold : .regular)
                .foregroundStyle(isToday ? .white : .primary)

            Circle()
                .fill(isPeriod ? Color(hex: "E91E63") : (isPredicted ? Color(hex: "E91E63").opacity(0.3) : Color.clear))
                .frame(width: 6, height: 6)
        }
        .frame(height: 40)
        .background(isToday ? Color(hex: "7C4DFF") : Color.clear)
        .clipShape(Circle())
    }

    private func daysInMonth() -> [Date] {
        guard let range = Calendar.current.range(of: .day, in: .month, for: displayedMonth) else { return [] }
        let components = Calendar.current.dateComponents([.year, .month], from: displayedMonth)
        return range.compactMap { day -> Date? in
            var comp = components
            comp.day = day
            return Calendar.current.date(from: comp)
        }
    }

    private func firstWeekdayOfMonth() -> Int {
        guard let firstDay = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: displayedMonth)) else { return 0 }
        return Calendar.current.component(.weekday, from: firstDay) - 1
    }

    private func changeMonth(_ delta: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: delta, to: displayedMonth) {
            displayedMonth = newMonth
        }
    }
}
