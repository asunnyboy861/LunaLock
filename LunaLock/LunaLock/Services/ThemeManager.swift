import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var accentColor: Color
    @Published var themeName: String

    private let defaults = UserDefaults.standard
    private let themeKey = "lunalock.theme"

    enum AppTheme: String, CaseIterable {
        case luna = "Luna"
        case rose = "Rose"
        case ocean = "Ocean"
        case forest = "Forest"
        case sunset = "Sunset"

        var color: Color {
            switch self {
            case .luna: return Color(hex: "7C4DFF")
            case .rose: return Color(hex: "E91E63")
            case .ocean: return Color(hex: "00BCD4")
            case .forest: return Color(hex: "4CAF50")
            case .sunset: return Color(hex: "FF9800")
            }
        }
    }

    init() {
        let saved = defaults.string(forKey: themeKey) ?? AppTheme.luna.rawValue
        let theme = AppTheme(rawValue: saved) ?? .luna
        accentColor = theme.color
        themeName = theme.rawValue
    }

    func setTheme(_ theme: AppTheme) {
        accentColor = theme.color
        themeName = theme.rawValue
        defaults.set(theme.rawValue, forKey: themeKey)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 122, 255)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
