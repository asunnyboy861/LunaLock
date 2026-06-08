import Foundation
import Combine
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var isReminderEnabled: Bool
    @Published var reminderDaysBefore: Int

    private let defaults = UserDefaults.standard
    private let reminderEnabledKey = "lunalock.reminder.enabled"
    private let reminderDaysKey = "lunalock.reminder.days"

    init() {
        isReminderEnabled = defaults.bool(forKey: reminderEnabledKey)
        reminderDaysBefore = defaults.integer(forKey: reminderDaysKey)
        if reminderDaysBefore == 0 { reminderDaysBefore = 2 }
    }

    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    func scheduleReminder(nextPeriodDate: Date) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        guard isReminderEnabled else { return }

        let triggerDate = Calendar.current.date(byAdding: .day, value: -reminderDaysBefore, to: nextPeriodDate) ?? nextPeriodDate

        let content = UNMutableNotificationContent()
        content.title = "LunaLock"
        content.body = "Your period is expected in \(reminderDaysBefore) days"
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: "lunalock.period.reminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func setReminderEnabled(_ enabled: Bool) {
        isReminderEnabled = enabled
        defaults.set(enabled, forKey: reminderEnabledKey)
    }

    func setReminderDays(_ days: Int) {
        reminderDaysBefore = days
        defaults.set(days, forKey: reminderDaysKey)
    }
}
