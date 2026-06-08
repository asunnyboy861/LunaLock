import SwiftUI

struct ThemePickerView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var purchaseManager = PurchaseManager.shared

    var body: some View {
        Group {
            if purchaseManager.isPro {
                proContent
            } else {
                lockedContent
            }
        }
        .navigationTitle("Themes")
    }

    private var proContent: some View {
        List {
            ForEach(ThemeManager.AppTheme.allCases, id: \.self) { theme in
                Button(action: { themeManager.setTheme(theme) }) {
                    HStack {
                        Circle()
                            .fill(theme.color)
                            .frame(width: 32, height: 32)
                        Text(theme.rawValue)
                            .font(.body)
                            .foregroundStyle(.primary)
                        Spacer()
                        if themeManager.themeName == theme.rawValue {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color(hex: "7C4DFF"))
                        }
                    }
                }
            }
        }
    }

    private var lockedContent: some View {
        VStack(spacing: 32) {
            Spacer()
            Image(systemName: "paintpalette.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color(hex: "7C4DFF"))
            Text("Theme Customization")
                .font(.title2)
                .fontWeight(.bold)
            Text("Choose from 5 beautiful color themes to personalize your experience.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
    }
}
