import Foundation

struct CyclePrediction {
    let nextPeriodDate: Date
    let daysUntilNext: Int
    let confidenceRange: Int
    let averageCycleLength: Double
    let currentPhase: CyclePhase
    let currentCycleDay: Int
}

enum CyclePhase: String {
    case menstrual = "Menstrual"
    case follicular = "Follicular"
    case luteal = "Luteal"
}
