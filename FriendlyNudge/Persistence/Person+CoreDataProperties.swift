import Foundation
import CoreData

extension Person {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Person> {
        return NSFetchRequest<Person>(entityName: "Person")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var birthday: Date?
    @NSManaged public var notes: String?
    @NSManaged public var cadenceRaw: String?
    @NSManaged public var lastConnectedDate: Date?
    @NSManaged public var snoozeUntil: Date?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var interactionLogs: NSSet?
    @NSManaged public var tags: NSSet?
}

// MARK: - Generated accessors for interactionLogs
extension Person {
    @objc(addInteractionLogsObject:)
    @NSManaged public func addToInteractionLogs(_ value: InteractionLog)

    @objc(removeInteractionLogsObject:)
    @NSManaged public func removeFromInteractionLogs(_ value: InteractionLog)

    @objc(addInteractionLogs:)
    @NSManaged public func addToInteractionLogs(_ values: NSSet)

    @objc(removeInteractionLogs:)
    @NSManaged public func removeFromInteractionLogs(_ values: NSSet)
}

// MARK: - Generated accessors for tags
extension Person {
    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: Tag)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: Tag)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)
}

extension Person: Identifiable {}
