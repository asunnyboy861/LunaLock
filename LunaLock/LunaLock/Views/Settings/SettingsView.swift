import SwiftUI

struct SettingsView: View {
    @StateObject private var security = SecurityManager.shared
    @StateObject private var purchaseManager = PurchaseManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @State private var showPaywall = false
    @State private var showDeleteConfirmation = false
    @State private var showPINSetup = false
    @State private var newPIN = ""
    @State private var healthKitEnabled = false

    private let dataStore = DataStore.shared

    var body: some View {
        NavigationStack {
            List {
                proSection
                securitySection
                notificationsSection
                appearanceSection
                dataSection
                legalSection
                aboutSection
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .alert("Delete All Data", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    dataStore.deleteAllData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all your period data. This action cannot be undone.")
            }
        }
    }

    private var proSection: some View {
        Section {
            if purchaseManager.isPro {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(Color(hex: "FFD700"))
                    Text("LunaLock Pro")
                        .foregroundStyle(.primary)
                    Spacer()
                    Text("Active")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            } else {
                Button(action: { showPaywall = true }) {
                    HStack {
                        Image(systemName: "crown")
                            .foregroundStyle(Color(hex: "7C4DFF"))
                        Text("Upgrade to Pro")
                            .foregroundStyle(Color(hex: "7C4DFF"))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var securitySection: some View {
        Section("Security") {
            Toggle("App Lock", isOn: Binding(
                get: { security.isSecurityEnabled },
                set: { security.setSecurityEnabled($0) }
            ))

            if security.isSecurityEnabled {
                Picker("Lock Method", selection: Binding(
                    get: { security.lockMethod },
                    set: { security.setLockMethod($0) }
                )) {
                    ForEach(SecurityManager.LockMethod.allCases, id: \.self) { method in
                        Label(method.rawValue, systemImage: method.icon).tag(method)
                    }
                }

                if security.lockMethod == .pin {
                    Button("Set PIN") {
                        showPINSetup = true
                    }
                    .alert("Set PIN", isPresented: $showPINSetup) {
                        SecureField("4-digit PIN", text: $newPIN)
                        Button("Save") {
                            if newPIN.count == 4 {
                                security.savePIN(newPIN)
                                newPIN = ""
                            }
                        }
                        Button("Cancel", role: .cancel) { newPIN = "" }
                    } message: {
                        Text("Enter a 4-digit PIN")
                    }
                }

                Picker("Auto-Lock", selection: Binding(
                    get: { security.autoLockDuration },
                    set: { security.setAutoLockDuration($0) }
                )) {
                    ForEach(SecurityManager.AutoLockDuration.allCases, id: \.self) { duration in
                        Text(duration.label).tag(duration)
                    }
                }
            }
        }
    }

    private var notificationsSection: some View {
        Section("Notifications") {
            Toggle("Period Reminder", isOn: Binding(
                get: { notificationManager.isReminderEnabled },
                set: { notificationManager.setReminderEnabled($0) }
            ))
            if notificationManager.isReminderEnabled {
                Stepper("Remind \(notificationManager.reminderDaysBefore) days before",
                        value: Binding(
                            get: { notificationManager.reminderDaysBefore },
                            set: { notificationManager.setReminderDays($0) }
                        ), in: 1...7)
            }
        }
    }

    private var appearanceSection: some View {
        Section("Appearance") {
            NavigationLink {
                ThemePickerView()
            } label: {
                HStack {
                    Text("Theme")
                    Spacer()
                    Circle()
                        .fill(themeManager.accentColor)
                        .frame(width: 20, height: 20)
                }
            }
        }
    }

    private var dataSection: some View {
        Section("Data") {
            NavigationLink("Export Data", destination: ExportView())

            if purchaseManager.isPro {
                Toggle("HealthKit Integration", isOn: $healthKitEnabled)
                    .onChange(of: healthKitEnabled) { _, newValue in
                        if newValue {
                            requestHealthKitPermission()
                        }
                    }
            }

            Button("Delete All Data", role: .destructive) {
                showDeleteConfirmation = true
            }

            if !purchaseManager.isPro {
                Button("Restore Purchases") {
                    Task { await purchaseManager.restorePurchases() }
                }
            }
        }
    }

    private var legalSection: some View {
        Section("Legal") {
            Link("Privacy Policy", destination: URL(string: "https://asunnyboy861.github.io/LunaLock/privacy.html")!)
            Link("Support", destination: URL(string: "https://asunnyboy861.github.io/LunaLock/support.html")!)
            if purchaseManager.isPro {
                Link("Terms of Use", destination: URL(string: "https://asunnyboy861.github.io/LunaLock/terms.html")!)
            }
        }
    }

    private var aboutSection: some View {
        Section("About") {
            NavigationLink("Contact Support", destination: ContactSupportView())
            HStack {
                Text("Version")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func requestHealthKitPermission() {
        // HealthKit write-only permission request
        // Will be configured when HealthKit capability is added
    }
}
