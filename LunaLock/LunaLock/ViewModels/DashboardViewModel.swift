import SwiftUI
import Combine

class DashboardViewModel: ObservableObject {
    @Published var prediction: CyclePrediction?
    @Published var todayRecord: DayRecord?
    @Published var selectedFlow: FlowLevel?
    @Published var selectedSymptoms: Set<SymptomType> = []
    @Published var selectedMood: MoodType?
    @Published var isOnPeriod = false

    private let dataStore = DataStore.shared
    private let predictor = CyclePredictor()

    func load() {
        prediction = predictor.predict(from: dataStore)
        let today = Calendar.current.startOfDay(for: Date())
        todayRecord = dataStore.getRecord(for: today)
        isOnPeriod = dataStore.isPeriodDay(today)
        selectedFlow = todayRecord?.flowLevel
        selectedSymptoms = todayRecord?.symptoms ?? []
        selectedMood = todayRecord?.mood
    }

    func logPeriodStart() {
        let flow = selectedFlow ?? .medium
        dataStore.logPeriodStart(flowLevel: flow)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        load()
    }

    func logPeriodEnd() {
        dataStore.logPeriodEnd()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        load()
    }

    func toggleSymptom(_ symptom: SymptomType) {
        dataStore.logSymptom(date: Date(), symptom: symptom)
        load()
    }

    func selectMood(_ mood: MoodType) {
        dataStore.logMood(date: Date(), mood: mood)
        load()
    }

    func selectFlow(_ flow: FlowLevel) {
        dataStore.logFlow(date: Date(), flow: flow)
        load()
    }

    var phaseColor: Color {
        switch prediction?.currentPhase {
        case .menstrual: return Color(hex: "E91E63")
        case .follicular: return Color(hex: "4CAF50")
        case .luteal: return Color(hex: "FF9800")
        case .none: return Color(hex: "7C4DFF")
        }
    }

    var phaseIcon: String {
        switch prediction?.currentPhase {
        case .menstrual: return "drop.fill"
        case .follicular: return "leaf.fill"
        case .luteal: return "flame.fill"
        case .none: return "moon.fill"
        }
    }
}
