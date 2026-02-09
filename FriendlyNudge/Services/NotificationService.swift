import SwiftUI
import UserNotifications

/// Keys for UserDefaults storage.
private enum NotificationSettingsKey {
    static let dailyReminderEnabled = "dailyReminderEnabled"
    static let reminderHour = "reminderHour"
    static let reminderMinute = "reminderMinute"
}

/// Default values for notification settings.
private enum NotificationDefaults {
    static let hour = 9
    static let minute = 0
}

/// Observable service managing notification preferences and authorization.
@MainActor
@Observable
final class NotificationService {
    // MARK: - Published State

    private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
    var dailyReminderEnabled: Bool {
        didSet {
            saveDailyReminderEnabled()
            Task { await syncSchedule() }
        }
    }

    var reminderTime: Date {
        didSet {
            saveReminderTime()
            Task { await syncSchedule() }
        }
    }

    // MARK: - Dependencies

    private let client: NotificationCenterClient
    private let userDefaults: UserDefaults

    // MARK: - Initialization

    init(
        client: NotificationCenterClient = LiveNotificationCenterClient(),
        userDefaults: UserDefaults = .standard
    ) {
        self.client = client
        self.userDefaults = userDefaults

        // Load saved preferences
        dailyReminderEnabled = userDefaults.bool(forKey: NotificationSettingsKey.dailyReminderEnabled)

        let savedHour = userDefaults.object(forKey: NotificationSettingsKey.reminderHour) as? Int
            ?? NotificationDefaults.hour
        let savedMinute = userDefaults.object(forKey: NotificationSettingsKey.reminderMinute) as? Int
            ?? NotificationDefaults.minute

        var components = DateComponents()
        components.hour = savedHour
        components.minute = savedMinute
        reminderTime = Calendar.current.date(from: components) ?? Date()
    }

    // MARK: - Public Methods

    /// Refreshes the current authorization status from the system.
    func refreshAuthorizationStatus() async {
        authorizationStatus = await client.authorizationStatus()
    }

    /// Requests notification authorization from the user.
    /// - Returns: Whether authorization was granted.
    @discardableResult
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await client.requestAuthorization(options: [.alert, .sound, .badge])
            await refreshAuthorizationStatus()
            if granted {
                await syncSchedule()
            }
            return granted
        } catch {
            await refreshAuthorizationStatus()
            return false
        }
    }

    /// Syncs the notification schedule based on current preferences.
    /// Call this on app launch to ensure notifications are properly scheduled.
    func syncSchedule() async {
        await refreshAuthorizationStatus()

        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: reminderTime)
        let minute = calendar.component(.minute, from: reminderTime)

        do {
            try await NotificationScheduler.sync(
                enabled: dailyReminderEnabled,
                hour: hour,
                minute: minute,
                authorizationStatus: authorizationStatus,
                client: client
            )
        } catch {
            // Silently fail - notifications are not critical
        }
    }

    /// Opens iOS Settings app to the app's notification settings.
    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Computed Properties

    /// The hour component of the reminder time.
    var reminderHour: Int {
        Calendar.current.component(.hour, from: reminderTime)
    }

    /// The minute component of the reminder time.
    var reminderMinute: Int {
        Calendar.current.component(.minute, from: reminderTime)
    }

    /// Whether notifications are authorized.
    var isAuthorized: Bool {
        authorizationStatus == .authorized
    }

    /// Whether authorization has been denied.
    var isDenied: Bool {
        authorizationStatus == .denied
    }

    /// Whether authorization is still undetermined.
    var isNotDetermined: Bool {
        authorizationStatus == .notDetermined
    }

    // MARK: - Private Methods

    private func saveDailyReminderEnabled() {
        userDefaults.set(dailyReminderEnabled, forKey: NotificationSettingsKey.dailyReminderEnabled)
    }

    private func saveReminderTime() {
        let calendar = Calendar.current
        userDefaults.set(calendar.component(.hour, from: reminderTime), forKey: NotificationSettingsKey.reminderHour)
        userDefaults.set(
            calendar.component(.minute, from: reminderTime),
            forKey: NotificationSettingsKey.reminderMinute
        )
    }
}
