import Foundation
import CoreData

extension InteractionLog {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<InteractionLog> {
        return NSFetchRequest<InteractionLog>(entityName: "InteractionLog")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var typeRaw: String?
    @NSManaged public var date: Date?
    @NSManaged public var note: String?
    @NSManaged public var person: Person?
}

extension InteractionLog: Identifiable {}
