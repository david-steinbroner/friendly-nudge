import CoreData
import Foundation

public extension Tag {
    @nonobjc class func fetchRequest() -> NSFetchRequest<Tag> {
        NSFetchRequest<Tag>(entityName: "Tag")
    }

    @NSManaged var id: UUID?
    @NSManaged var name: String?
    @NSManaged var people: NSSet?
}

// MARK: - Generated accessors for people

public extension Tag {
    @objc(addPeopleObject:)
    @NSManaged func addToPeople(_ value: Person)

    @objc(removePeopleObject:)
    @NSManaged func removeFromPeople(_ value: Person)

    @objc(addPeople:)
    @NSManaged func addToPeople(_ values: NSSet)

    @objc(removePeople:)
    @NSManaged func removeFromPeople(_ values: NSSet)
}

extension Tag: Identifiable {}
