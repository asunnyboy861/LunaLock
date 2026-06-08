import SwiftUI
import Combine

class CalendarViewModel: ObservableObject {
    @Published var selectedDate = Date()
    @Published var records: [Date: DayRecord] = [:]
    @Published var predictedDates: Set<Date> = []

    private let dataStore = DataStore.shared
    private let predictor = CyclePredictor()

    func load() {
        records = dataStore.records
        if let prediction = predictor.predict(from: dataStore) {
            var predicted = Set<Date>()
            let start = prediction.nextPeriodDate
            for dayOffset in 0..<5 {
                if let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: start) {
                    predicted.insert(Calendar.current.startOfDay(for: date))
                }
            }
            predictedDates = predicted
        }
    }

    func record(for date: Date) -> DayRecord? {
        let key = Calendar.current.startOfDay(for: date)
        return records[key]
    }

    func isPeriodDay(_ date: Date) -> Bool {
        return dataStore.isPeriodDay(date)
    }

    func isPredictedDay(_ date: Date) -> Bool {
        let key = Calendar.current.startOfDay(for: date)
        return predictedDates.contains(key)
    }

    func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
}
