import Foundation
import Combine
import LocalAuthentication

class SecurityManager: ObservableObject {
    static let shared = SecurityManager()

    @Published var isLocked = true
    @Published var isSecurityEnabled: Bool
    @Published var lockMethod: LockMethod
    @Published var autoLockDuration: AutoLockDuration

    private let defaults = UserDefaults.standard
    private let securityEnabledKey = "lunalock.security.enabled"
    private let lockMethodKey = "lunalock.lock.method"
    private let autoLockKey = "lunalock.autolock.duration"
    private let pinKey = "lunalock.pin"
    private var lastUnlockTime: Date?
    private var autoLockTimer: Timer?

    enum LockMethod: String, CaseIterable {
        case faceID = "FaceID"
        case pin = "PIN"

        var icon: String {
            switch self {
            case .faceID: return "faceid"
            case .pin: return "lock.fill"
            }
        }
    }

    enum AutoLockDuration: Double, CaseIterable {
        case immediately = 0
        case oneMinute = 60
        case fiveMinutes = 300
        case fifteenMinutes = 900

        var label: String {
            switch self {
            case .immediately: return "Immediately"
            case .oneMinute: return "1 Minute"
            case .fiveMinutes: return "5 Minutes"
            case .fifteenMinutes: return "15 Minutes"
            }
        }
    }

    init() {
        isSecurityEnabled = defaults.bool(forKey: securityEnabledKey)
        let methodRaw = defaults.string(forKey: lockMethodKey) ?? LockMethod.faceID.rawValue
        lockMethod = LockMethod(rawValue: methodRaw) ?? .faceID
        let durationRaw = defaults.double(forKey: autoLockKey)
        autoLockDuration = AutoLockDuration(rawValue: durationRaw) ?? .immediately
        isLocked = isSecurityEnabled
    }

    func authenticate(completion: @escaping (Bool) -> Void) {
        if !isSecurityEnabled {
            isLocked = false
            completion(true)
            return
        }

        switch lockMethod {
        case .faceID:
            let context = LAContext()
            var error: NSError?
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock LunaLock") { success, _ in
                    DispatchQueue.main.async {
                        if success {
                            self.isLocked = false
                            self.lastUnlockTime = Date()
                            self.scheduleAutoLock()
                        }
                        completion(success)
                    }
                }
            } else {
                let fallbackContext = LAContext()
                fallbackContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Unlock LunaLock") { success, _ in
                    DispatchQueue.main.async {
                        if success {
                            self.isLocked = false
                            self.lastUnlockTime = Date()
                            self.scheduleAutoLock()
                        }
                        completion(success)
                    }
                }
            }
        case .pin:
            // PIN mode: don't auto-unlock here, let LockScreenView handle PIN input
            completion(false)
        }
    }

    func lockNow() {
        isLocked = true
        autoLockTimer?.invalidate()
        autoLockTimer = nil
    }

    func emergencyLock() {
        lockNow()
    }

    func setSecurityEnabled(_ enabled: Bool) {
        isSecurityEnabled = enabled
        defaults.set(enabled, forKey: securityEnabledKey)
        if !enabled {
            isLocked = false
        }
    }

    func setLockMethod(_ method: LockMethod) {
        lockMethod = method
        defaults.set(method.rawValue, forKey: lockMethodKey)
    }

    func setAutoLockDuration(_ duration: AutoLockDuration) {
        autoLockDuration = duration
        defaults.set(duration.rawValue, forKey: autoLockKey)
    }

    func savePIN(_ pin: String) {
        defaults.set(pin, forKey: pinKey)
    }

    func verifyPIN(_ pin: String) -> Bool {
        return defaults.string(forKey: pinKey) == pin
    }

    private func scheduleAutoLock() {
        autoLockTimer?.invalidate()
        guard autoLockDuration != .immediately else { return }
        autoLockTimer = Timer.scheduledTimer(withTimeInterval: autoLockDuration.rawValue, repeats: false) { [weak self] _ in
            self?.lockNow()
        }
    }
}
