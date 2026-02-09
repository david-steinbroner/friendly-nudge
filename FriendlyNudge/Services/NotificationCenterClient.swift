import UserNotifications

/// Protocol wrapping UNUserNotificationCenter for testability.
protocol NotificationCenterClient: Sendable {
    func authorizationStatus() async -> UNAuthorizationStatus
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool
    func add(_ request: UNNotificationRequest) async throws
    func removePendingNotificationRequests(withIdentifiers identifiers: [String])
    func removeDeliveredNotifications(withIdentifiers identifiers: [String])
    func pendingNotificationRequests() async -> [UNNotificationRequest]
}

/// Live implementation using UNUserNotificationCenter.
struct LiveNotificationCenterClient: NotificationCenterClient {
    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func authorizationStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }

    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        try await center.requestAuthorization(options: options)
    }

    func add(_ request: UNNotificationRequest) async throws {
        try await center.add(request)
    }

    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func removeDeliveredNotifications(withIdentifiers identifiers: [String]) {
        center.removeDeliveredNotifications(withIdentifiers: identifiers)
    }

    func pendingNotificationRequests() async -> [UNNotificationRequest] {
        await center.pendingNotificationRequests()
    }
}

/// Mock implementation for unit tests.
final class MockNotificationCenterClient: NotificationCenterClient, @unchecked Sendable {
    var mockAuthorizationStatus: UNAuthorizationStatus = .notDetermined
    var requestAuthorizationResult: Result<Bool, Error> = .success(true)
    var addedRequests: [UNNotificationRequest] = []
    var removedPendingIdentifiers: [String] = []
    var removedDeliveredIdentifiers: [String] = []
    var pendingRequests: [UNNotificationRequest] = []

    func authorizationStatus() async -> UNAuthorizationStatus {
        mockAuthorizationStatus
    }

    func requestAuthorization(options _: UNAuthorizationOptions) async throws -> Bool {
        switch requestAuthorizationResult {
        case let .success(granted):
            if granted {
                mockAuthorizationStatus = .authorized
            }
            return granted
        case let .failure(error):
            throw error
        }
    }

    func add(_ request: UNNotificationRequest) async throws {
        addedRequests.append(request)
    }

    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        removedPendingIdentifiers.append(contentsOf: identifiers)
        pendingRequests.removeAll { identifiers.contains($0.identifier) }
    }

    func removeDeliveredNotifications(withIdentifiers identifiers: [String]) {
        removedDeliveredIdentifiers.append(contentsOf: identifiers)
    }

    func pendingNotificationRequests() async -> [UNNotificationRequest] {
        pendingRequests
    }

    func reset() {
        mockAuthorizationStatus = .notDetermined
        requestAuthorizationResult = .success(true)
        addedRequests = []
        removedPendingIdentifiers = []
        removedDeliveredIdentifiers = []
        pendingRequests = []
    }
}
