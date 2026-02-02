import CoreData
import Foundation

public extension Person {
    @nonobjc class func fetchRequest() -> NSFetchRequest<Person> {
        NSFetchRequest<Person>(entityName: "Person")
    }

    @NSManaged var id: UUID?
    @NSManaged var name: String?
    @NSManaged var birthday: Date?
    @NSManaged var notes: String?
    @NSManaged var cadenceRaw: String?
    @NSManaged var lastConnectedDate: Date?
    @NSManaged var snoozeUntil: Date?
    @NSManaged var createdAt: Date?
    @NSManaged var updatedAt: Date?
    @NSManaged var interactionLogs: NSSet?
    @NSManaged var tags: NSSet?
}

// MARK: - Generated accessors for interactionLogs

public extension Person {
    @objc(addInteractionLogsObject:)
    @NSManaged func addToInteractionLogs(_ value: InteractionLog)

    @objc(removeInteractionLogsObject:)
    @NSManaged func removeFromInteractionLogs(_ value: InteractionLog)

    @objc(addInteractionLogs:)
    @NSManaged func addToInteractionLogs(_ values: NSSet)

    @objc(removeInteractionLogs:)
    @NSManaged func removeFromInteractionLogs(_ values: NSSet)
}

// MARK: - Generated accessors for tags

public extension Person {
    @objc(addTagsObject:)
    @NSManaged func addToTags(_ value: Tag)

    @objc(removeTagsObject:)
    @NSManaged func removeFromTags(_ value: Tag)

    @objc(addTags:)
    @NSManaged func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged func removeFromTags(_ values: NSSet)
}

extension Person: Identifiable {}
