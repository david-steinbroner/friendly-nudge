import CoreData
import Foundation

public extension InteractionLog {
    @nonobjc class func fetchRequest() -> NSFetchRequest<InteractionLog> {
        NSFetchRequest<InteractionLog>(entityName: "InteractionLog")
    }

    @NSManaged var id: UUID?
    @NSManaged var typeRaw: String?
    @NSManaged var date: Date?
    @NSManaged var note: String?
    @NSManaged var person: Person?
}

extension InteractionLog: Identifiable {}
