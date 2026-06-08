import Foundation

class CyclePredictor {
    func predict(from dataStore: DataStore) -> CyclePrediction? {
        let starts = dataStore.periodStartDates
        guard let lastStart = starts.last else { return nil }

        let currentCycleDay: Int
        if starts.count >= 1 {
            currentCycleDay = max(1, Calendar.current.dateComponents([.day], from: lastStart, to: Date()).day ?? 1)
        } else {
            return nil
        }

        var avgCycleLength: Double = 28.0
        var confidenceRange: Int = 4

        if starts.count >= 2 {
            var intervals: [Int] = []
            for i in 1..<starts.count {
                let days = Calendar.current.dateComponents([.day], from: starts[i-1], to: starts[i]).day ?? 28
                if days >= 15 && days <= 45 {
                    intervals.append(days)
                }
            }

            if !intervals.isEmpty {
                let recentIntervals = Array(intervals.suffix(min(6, intervals.count)))
                let weights = recentIntervals.enumerated().map { Double($0.offset + 1) }
                let totalWeight = weights.reduce(0, +)
                avgCycleLength = zip(recentIntervals, weights).reduce(0.0) { $0 + Double($1.0) * $1.1 } / totalWeight

                if intervals.count >= 3 {
                    let mean = intervals.reduce(0, +) / intervals.count
                    let variance = intervals.reduce(0) { $0 + ($1 - mean) * ($1 - mean) } / intervals.count
                    let stdDev = sqrt(Double(variance))
                    confidenceRange = max(1, Int(ceil(stdDev * 1.96)))
                } else {
                    confidenceRange = 4
                }
            }
        }

        let nextPeriodDate = Calendar.current.date(byAdding: .day, value: Int(avgCycleLength), to: lastStart) ?? lastStart
        let daysUntilNext = max(0, Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: nextPeriodDate)).day ?? 0)

        let phase: CyclePhase
        if currentCycleDay <= 5 {
            phase = .menstrual
        } else if currentCycleDay <= 13 {
            phase = .follicular
        } else {
            phase = .luteal
        }

        return CyclePrediction(
            nextPeriodDate: nextPeriodDate,
            daysUntilNext: daysUntilNext,
            confidenceRange: confidenceRange,
            averageCycleLength: avgCycleLength,
            currentPhase: phase,
            currentCycleDay: currentCycleDay
        )
    }
}
