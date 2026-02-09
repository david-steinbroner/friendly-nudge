import CoreData
import Foundation

// MARK: - Export DTOs

/// Root envelope for exported data.
struct ExportEnvelope: Codable, Equatable {
    let schemaVersion: Int
    let exportedAt: String
    let appVersion: String
    let appBuild: String
    let data: ExportData

    static let currentSchemaVersion = 1
}

/// Container for all exported entity arrays and settings.
struct ExportData: Codable, Equatable {
    let people: [PersonDTO]
    let tags: [TagDTO]
    let interactionLogs: [InteractionLogDTO]
    let settings: SettingsDTO
}

/// Exported representation of a Person entity.
struct PersonDTO: Codable, Equatable {
    let id: String
    let name: String
    let birthday: String?
    let notes: String?
    let cadence: String
    let lastConnectedDate: String?
    let snoozeUntil: String?
    let createdAt: String
    let updatedAt: String
    let tagIDs: [String]
}

/// Exported representation of a Tag entity.
struct TagDTO: Codable, Equatable {
    let id: String
    let name: String
}

/// Exported representation of an InteractionLog entity.
struct InteractionLogDTO: Codable, Equatable {
    let id: String
    let personID: String?
    let type: String
    let date: String
    let note: String?
}

/// Exported user settings from UserDefaults.
struct SettingsDTO: Codable, Equatable {
    let dailyReminderEnabled: Bool
    let reminderHour: Int
    let reminderMinute: Int
}

// MARK: - Export Result

enum ExportResult {
    case success(URL)
    case failure(ExportError)
}

enum ExportError: Error, LocalizedError {
    case encodingFailed
    case writeFailed

    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            "Failed to encode data for export."
        case .writeFailed:
            "Failed to write export file."
        }
    }
}

// MARK: - Export Service

enum ExportService {
    // MARK: - UserDefaults Keys (must match NotificationService)

    private enum SettingsKey {
        static let dailyReminderEnabled = "dailyReminderEnabled"
        static let reminderHour = "reminderHour"
        static let reminderMinute = "reminderMinute"
    }

    private enum SettingsDefaults {
        static let hour = 9
        static let minute = 0
    }

    // MARK: - Public API

    /// Exports all user data to a JSON file.
    /// - Parameters:
    ///   - context: The Core Data context to fetch from.
    ///   - userDefaults: The UserDefaults to read settings from.
    ///   - bundle: The bundle to read app version from.
    ///   - fileManager: The file manager for writing files.
    ///   - dateProvider: Closure that returns the current date (for testing).
    /// - Returns: URL to the exported file on success, or an error.
    static func exportAllData(
        context: NSManagedObjectContext,
        userDefaults: UserDefaults = .standard,
        bundle: Bundle = .main,
        fileManager: FileManager = .default,
        dateProvider: () -> Date = { Date() }
    ) -> ExportResult {
        let envelope = buildEnvelope(
            context: context,
            userDefaults: userDefaults,
            bundle: bundle,
            dateProvider: dateProvider
        )

        return writeToFile(
            envelope: envelope,
            fileManager: fileManager,
            dateProvider: dateProvider
        )
    }

    /// Builds an export envelope with all data (exposed for testing).
    static func buildEnvelope(
        context: NSManagedObjectContext,
        userDefaults: UserDefaults = .standard,
        bundle: Bundle = .main,
        dateProvider: () -> Date = { Date() }
    ) -> ExportEnvelope {
        let people = fetchPeople(context: context)
        let tags = fetchTags(context: context)
        let logs = fetchInteractionLogs(context: context)
        let settings = fetchSettings(userDefaults: userDefaults)

        let peopleDTOs = people.map { mapPerson($0) }
        let tagDTOs = tags.map { mapTag($0) }
        let logDTOs = logs.map { mapInteractionLog($0) }

        let data = ExportData(
            people: peopleDTOs,
            tags: tagDTOs,
            interactionLogs: logDTOs,
            settings: settings
        )

        let exportedAt = ISO8601DateFormatter().string(from: dateProvider())
        let appVersion = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown"
        let appBuild = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "unknown"

        return ExportEnvelope(
            schemaVersion: ExportEnvelope.currentSchemaVersion,
            exportedAt: exportedAt,
            appVersion: appVersion,
            appBuild: appBuild,
            data: data
        )
    }

    // MARK: - Fetch Methods (deterministic ordering)

    private static func fetchPeople(context: NSManagedObjectContext) -> [Person] {
        let request: NSFetchRequest<Person> = Person.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Person.createdAt, ascending: true),
            NSSortDescriptor(keyPath: \Person.id, ascending: true),
        ]
        return (try? context.fetch(request)) ?? []
    }

    private static func fetchTags(context: NSManagedObjectContext) -> [Tag] {
        let request: NSFetchRequest<Tag> = Tag.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Tag.name, ascending: true),
            NSSortDescriptor(keyPath: \Tag.id, ascending: true),
        ]
        return (try? context.fetch(request)) ?? []
    }

    private static func fetchInteractionLogs(context: NSManagedObjectContext) -> [InteractionLog] {
        let request: NSFetchRequest<InteractionLog> = InteractionLog.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \InteractionLog.date, ascending: true),
            NSSortDescriptor(keyPath: \InteractionLog.id, ascending: true),
        ]
        return (try? context.fetch(request)) ?? []
    }

    private static func fetchSettings(userDefaults: UserDefaults) -> SettingsDTO {
        SettingsDTO(
            dailyReminderEnabled: userDefaults.bool(forKey: SettingsKey.dailyReminderEnabled),
            reminderHour: userDefaults.object(forKey: SettingsKey.reminderHour) as? Int ?? SettingsDefaults.hour,
            reminderMinute: userDefaults.object(forKey: SettingsKey.reminderMinute) as? Int ?? SettingsDefaults.minute
        )
    }

    // MARK: - Mapping Methods

    private static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static func formatDate(_ date: Date?) -> String? {
        guard let date else { return nil }
        return iso8601Formatter.string(from: date)
    }

    private static func formatDateRequired(_ date: Date?) -> String {
        formatDate(date) ?? iso8601Formatter.string(from: Date.distantPast)
    }

    private static func mapPerson(_ person: Person) -> PersonDTO {
        let tagIDs: [String] = (person.tags as? Set<Tag>)?
            .compactMap { $0.id?.uuidString }
            .sorted() ?? []

        return PersonDTO(
            id: person.id?.uuidString ?? UUID().uuidString,
            name: person.name ?? "",
            birthday: formatDate(person.birthday),
            notes: person.notes,
            cadence: person.cadenceRaw ?? Cadence.none.rawValue,
            lastConnectedDate: formatDate(person.lastConnectedDate),
            snoozeUntil: formatDate(person.snoozeUntil),
            createdAt: formatDateRequired(person.createdAt),
            updatedAt: formatDateRequired(person.updatedAt),
            tagIDs: tagIDs
        )
    }

    private static func mapTag(_ tag: Tag) -> TagDTO {
        TagDTO(
            id: tag.id?.uuidString ?? UUID().uuidString,
            name: tag.name ?? ""
        )
    }

    private static func mapInteractionLog(_ log: InteractionLog) -> InteractionLogDTO {
        InteractionLogDTO(
            id: log.id?.uuidString ?? UUID().uuidString,
            personID: log.person?.id?.uuidString,
            type: log.typeRaw ?? InteractionType.other.rawValue,
            date: formatDateRequired(log.date),
            note: log.note
        )
    }

    // MARK: - File Writing

    private static func writeToFile(
        envelope: ExportEnvelope,
        fileManager: FileManager,
        dateProvider: () -> Date
    ) -> ExportResult {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        guard let jsonData = try? encoder.encode(envelope) else {
            return .failure(.encodingFailed)
        }

        let timestamp = makeTimestamp(from: dateProvider())
        let fileName = "friendly-nudge-export-\(timestamp).json"
        let tempURL = fileManager.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try jsonData.write(to: tempURL, options: .atomic)
            return .success(tempURL)
        } catch {
            return .failure(.writeFailed)
        }
    }

    private static func makeTimestamp(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        formatter.timeZone = .current
        return formatter.string(from: date)
    }
}
