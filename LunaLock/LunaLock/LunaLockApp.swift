import SwiftUI

@main
struct LunaLockApp: App {
    @AppStorage("lunalock.onboarding.complete") private var onboardingComplete = false
    @StateObject private var security = SecurityManager.shared
    @StateObject private var themeManager = ThemeManager.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if !onboardingComplete {
                    PrivacyPromiseView()
                } else if security.isLocked && security.isSecurityEnabled {
                    LockScreenView()
                } else {
                    ContentView()
                }
            }
            .tint(themeManager.accentColor)
        }
    }
}
