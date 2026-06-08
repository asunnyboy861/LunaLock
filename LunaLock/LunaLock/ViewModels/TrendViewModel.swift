import SwiftUI
import Combine

class TrendViewModel: ObservableObject {
    @Published var cycleLengths: [Double] = []
    @Published var symptomFrequency: [SymptomType: Int] = [:]
    @Published var moodDistribution: [MoodType: Int] = [:]
    @Published var periodLengths: [Double] = []

    private let dataStore = DataStore.shared

    func load() {
        var lengths: [Double] = []
        var pLengths: [Double] = []
        var symptoms: [SymptomType: Int] = [:]
        var moods: [MoodType: Int] = [:]

        for record in dataStore.records.values {
            if let cl = record.cycleLength {
                lengths.append(Double(cl))
            }
            if let pl = record.periodLength {
                pLengths.append(Double(pl))
            }
            for symptom in record.symptoms {
                symptoms[symptom, default: 0] += 1
            }
            if let mood = record.mood {
                moods[mood, default: 0] += 1
            }
        }

        cycleLengths = lengths
        periodLengths = pLengths
        symptomFrequency = symptoms
        moodDistribution = moods
    }

    var averageCycleLength: Double {
        cycleLengths.isEmpty ? 0 : cycleLengths.reduce(0, +) / Double(cycleLengths.count)
    }

    var averagePeriodLength: Double {
        periodLengths.isEmpty ? 0 : periodLengths.reduce(0, +) / Double(periodLengths.count)
    }

    var topSymptoms: [(SymptomType, Int)] {
        symptomFrequency.sorted { $0.value > $1.value }.prefix(3).map { ($0.key, $0.value) }
    }

    var topMoods: [(MoodType, Int)] {
        moodDistribution.sorted { $0.value > $1.value }.prefix(3).map { ($0.key, $0.value) }
    }
}
