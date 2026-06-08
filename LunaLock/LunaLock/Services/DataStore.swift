import Foundation
import Combine

struct DayRecord: Identifiable, Codable {
    let id: UUID
    let date: Date
    var isPeriodStart: Bool
    var isPeriodEnd: Bool
    var flowLevel: FlowLevel?
    var symptomsList: [SymptomType]
    var mood: MoodType?
    var customSymptoms: [String]
    var cycleLength: Int?
    var periodLength: Int?

    var symptoms: Set<SymptomType> {
        get { Set(symptomsList) }
        set { symptomsList = Array(newValue) }
    }

    init(id: UUID = UUID(), date: Date, isPeriodStart: Bool, isPeriodEnd: Bool, flowLevel: FlowLevel? = nil, symptoms: Set<SymptomType> = [], mood: MoodType? = nil, customSymptoms: [String] = [], cycleLength: Int? = nil, periodLength: Int? = nil) {
        self.id = id
        self.date = date
        self.isPeriodStart = isPeriodStart
        self.isPeriodEnd = isPeriodEnd
        self.flowLevel = flowLevel
        self.symptomsList = Array(symptoms)
        self.mood = mood
        self.customSymptoms = customSymptoms
        self.cycleLength = cycleLength
        self.periodLength = periodLength
    }

    enum CodingKeys: String, CodingKey {
        case id, date, isPeriodStart, isPeriodEnd, flowLevel, symptomsList, mood, customSymptoms, cycleLength, periodLength
    }
}

class DataStore: ObservableObject {
    static let shared = DataStore()

    @Published var records: [Date: DayRecord] = [:]
    @Published var periodStartDates: [Date] = []

    private let defaults = UserDefaults.standard
    private let recordsKey = "lunalock.records"
    private let periodsKey = "lunalock.periods"

    init() {
        loadRecords()
    }

    func logPeriodStart(date: Date = Date(), flowLevel: FlowLevel = .medium) {
        let key = Calendar.current.startOfDay(for: date)
        var record = records[key] ?? DayRecord(date: key, isPeriodStart: false, isPeriodEnd: false, symptoms: [], customSymptoms: [])
        record.isPeriodStart = true
        record.flowLevel = flowLevel
        records[key] = record

        periodStartDates.append(key)
        periodStartDates.sort()

        if periodStartDates.count >= 2 {
            let prevIndex = periodStartDates.count - 2
            let prevDate = periodStartDates[prevIndex]
            let prevKey = Calendar.current.startOfDay(for: prevDate)
            let days = Calendar.current.dateComponents([.day], from: prevKey, to: key).day ?? 28
            if var prevRecord = records[prevKey] {
                prevRecord.cycleLength = days
                records[prevKey] = prevRecord
            }
        }

        saveRecords()
    }

    func logPeriodEnd(date: Date = Date()) {
        let key = Calendar.current.startOfDay(for: date)
        var record = records[key] ?? DayRecord(date: key, isPeriodStart: false, isPeriodEnd: false, symptoms: [], customSymptoms: [])
        record.isPeriodEnd = true
        records[key] = record

        if let lastStart = periodStartDates.last {
            let startKey = Calendar.current.startOfDay(for: lastStart)
            let days = Calendar.current.dateComponents([.day], from: startKey, to: key).day ?? 5
            if var startRecord = records[startKey] {
                startRecord.periodLength = days
                records[startKey] = startRecord
            }
        }

        saveRecords()
    }

    func logSymptom(date: Date, symptom: SymptomType) {
        let key = Calendar.current.startOfDay(for: date)
        var record = records[key] ?? DayRecord(date: key, isPeriodStart: false, isPeriodEnd: false, symptoms: [], customSymptoms: [])
        if record.symptoms.contains(symptom) {
            record.symptoms.remove(symptom)
        } else {
            record.symptoms.insert(symptom)
        }
        records[key] = record
        saveRecords()
    }

    func logMood(date: Date, mood: MoodType) {
        let key = Calendar.current.startOfDay(for: date)
        var record = records[key] ?? DayRecord(date: key, isPeriodStart: false, isPeriodEnd: false, symptoms: [], customSymptoms: [])
        record.mood = mood
        records[key] = record
        saveRecords()
    }

    func logFlow(date: Date, flow: FlowLevel) {
        let key = Calendar.current.startOfDay(for: date)
        var record = records[key] ?? DayRecord(date: key, isPeriodStart: false, isPeriodEnd: false, symptoms: [], customSymptoms: [])
        record.flowLevel = flow
        records[key] = record
        saveRecords()
    }

    func deleteAllData() {
        records.removeAll()
        periodStartDates.removeAll()
        defaults.removeObject(forKey: recordsKey)
        defaults.removeObject(forKey: periodsKey)
    }

    func getRecord(for date: Date) -> DayRecord? {
        let key = Calendar.current.startOfDay(for: date)
        return records[key]
    }

    func isPeriodDay(_ date: Date) -> Bool {
        let key = Calendar.current.startOfDay(for: date)
        guard let record = records[key] else { return false }
        return record.isPeriodStart || record.flowLevel != nil
    }

    private func saveRecords() {
        if let encoded = try? JSONEncoder().encode(Array(records.values)) {
            defaults.set(encoded, forKey: recordsKey)
        }
        if let encoded = try? JSONEncoder().encode(periodStartDates) {
            defaults.set(encoded, forKey: periodsKey)
        }
        objectWillChange.send()
    }

    private func loadRecords() {
        if let data = defaults.data(forKey: recordsKey),
           let decoded = try? JSONDecoder().decode([DayRecord].self, from: data) {
            for record in decoded {
                let key = Calendar.current.startOfDay(for: record.date)
                records[key] = record
            }
        }
        if let data = defaults.data(forKey: periodsKey),
           let decoded = try? JSONDecoder().decode([Date].self, from: data) {
            periodStartDates = decoded.sorted()
        }
    }
}
