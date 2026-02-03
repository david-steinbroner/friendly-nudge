import CoreData
import Foundation

@objc(Person)
public class Person: NSManagedObject {
    var cadence: Cadence {
        get {
            Cadence(rawValue: cadenceRaw ?? "none") ?? .none
        }
        set {
            cadenceRaw = newValue.rawValue
        }
    }

    static func isValidName(_ name: String) -> Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var sortedInteractions: [InteractionLog] {
        let logs = interactionLogs as? Set<InteractionLog> ?? []
        return logs.sorted { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) }
    }
}
