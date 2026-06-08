import Foundation

enum SymptomType: String, CaseIterable, Codable {
    case cramps = "Cramps"
    case bloating = "Bloating"
    case headache = "Headache"
    case fatigue = "Fatigue"
    case acne = "Acne"
    case moodSwings = "Mood Swings"

    var icon: String {
        switch self {
        case .cramps: return "figure.stomachache"
        case .bloating: return "drop.fill"
        case .headache: return "brain.head.profile"
        case .fatigue: return "bed.double.fill"
        case .acne: return "face.dashed"
        case .moodSwings: return "heart.circle"
        }
    }
}

enum MoodType: String, CaseIterable, Codable {
    case happy = "Happy"
    case calm = "Calm"
    case anxious = "Anxious"
    case sad = "Sad"
    case irritable = "Irritable"
    case energetic = "Energetic"

    var icon: String {
        switch self {
        case .happy: return "face.smiling"
        case .calm: return "leaf.fill"
        case .anxious: return "wind"
        case .sad: return "cloud.rain.fill"
        case .irritable: return "bolt.fill"
        case .energetic: return "flame.fill"
        }
    }
}

enum FlowLevel: Int, CaseIterable, Codable {
    case spotting = 1
    case light = 2
    case medium = 3
    case heavy = 4

    var label: String {
        switch self {
        case .spotting: return "Spotting"
        case .light: return "Light"
        case .medium: return "Medium"
        case .heavy: return "Heavy"
        }
    }
}
