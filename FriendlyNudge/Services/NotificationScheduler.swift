import UserNotifications

/// Identifier for the daily nudge notification.
enum NotificationIdentifier {
    static let dailyNudge = "dailyNudge"
}

/// Result of a scheduling operation.
enum ScheduleResult: Equatable {
    case scheduled(hour: Int, minute: Int)
    case canceled
    case notAuthorized
    case disabled
}

/// Pure logic for scheduling notifications.
/// Takes dependencies (client, preferences, auth status) and performs side effects.
enum NotificationScheduler {
    /// Syncs the notification schedule based on current preferences and authorization.
    ///
    /// - Parameters:
    ///   - enabled: Whether the daily reminder is enabled in settings.
    ///   - hour: The hour to schedule the notification (0-23).
    ///   - minute: The minute to schedule the notification (0-59).
    ///   - authorizationStatus: Current notification authorization status.
    ///   - client: The notification center client to use.
    /// - Returns: The result of the scheduling operation.
    @discardableResult
    static func sync(
        enabled: Bool,
        hour: Int,
        minute: Int,
        authorizationStatus: UNAuthorizationStatus,
        client: NotificationCenterClient
    ) async throws -> ScheduleResult {
        // Always remove existing to avoid duplicates
        client.removePendingNotificationRequests(withIdentifiers: [NotificationIdentifier.dailyNudge])
        client.removeDeliveredNotifications(withIdentifiers: [NotificationIdentifier.dailyNudge])

        guard enabled else {
            return .disabled
        }

        guard authorizationStatus == .authorized else {
            return .notAuthorized
        }

        let content = UNMutableNotificationContent()
        content.title = "Friendly nudge"
        content.body = "Check in with someone you care about."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: NotificationIdentifier.dailyNudge,
            content: content,
            trigger: trigger
        )

        try await client.add(request)
        return .scheduled(hour: hour, minute: minute)
    }

    /// Cancels all daily nudge notifications.
    static func cancel(client: NotificationCenterClient) {
        client.removePendingNotificationRequests(withIdentifiers: [NotificationIdentifier.dailyNudge])
        client.removeDeliveredNotifications(withIdentifiers: [NotificationIdentifier.dailyNudge])
    }

    /// Creates the trigger DateComponents for testing purposes.
    static func triggerComponents(hour: Int, minute: Int) -> DateComponents {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        return components
    }
}
