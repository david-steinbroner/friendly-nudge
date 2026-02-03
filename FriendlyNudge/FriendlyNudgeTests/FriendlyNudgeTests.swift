import CoreData
import XCTest
@testable import FriendlyNudge

final class CadenceTests: XCTestCase {
    func testCadenceDisplayNames() {
        XCTAssertEqual(Cadence.weekly.displayName, "Weekly")
        XCTAssertEqual(Cadence.monthly.displayName, "Monthly")
        XCTAssertEqual(Cadence.quarterly.displayName, "Quarterly")
        XCTAssertEqual(Cadence.none.displayName, "None")
    }

    func testCadenceRawValues() {
        XCTAssertEqual(Cadence.weekly.rawValue, "weekly")
        XCTAssertEqual(Cadence.monthly.rawValue, "monthly")
        XCTAssertEqual(Cadence.quarterly.rawValue, "quarterly")
        XCTAssertEqual(Cadence.none.rawValue, "none")
    }

    func testCadenceAllCases() {
        XCTAssertEqual(Cadence.allCases.count, 4)
    }
}

final class InteractionTypeTests: XCTestCase {
    func testInteractionTypeDisplayNames() {
        XCTAssertEqual(InteractionType.texted.displayName, "Texted")
        XCTAssertEqual(InteractionType.called.displayName, "Called")
        XCTAssertEqual(InteractionType.hungOut.displayName, "Hung Out")
        XCTAssertEqual(InteractionType.other.displayName, "Other")
    }

    func testInteractionTypeIconNames() {
        XCTAssertEqual(InteractionType.texted.iconName, "message")
        XCTAssertEqual(InteractionType.called.iconName, "phone")
        XCTAssertEqual(InteractionType.hungOut.iconName, "person.2")
        XCTAssertEqual(InteractionType.other.iconName, "ellipsis.circle")
    }

    func testInteractionTypeAllCases() {
        XCTAssertEqual(InteractionType.allCases.count, 4)
    }
}

final class PersistenceControllerTests: XCTestCase {
    func testInMemoryStoreInitializes() {
        let controller = PersistenceController(inMemory: true)
        XCTAssertNotNil(controller.container)
        XCTAssertNotNil(controller.container.viewContext)
    }
}

// MARK: - Person Edit Tests (SKU-361)

final class PersonValidationTests: XCTestCase {
    func testEmptyNameIsInvalid() {
        XCTAssertFalse(Person.isValidName(""))
    }

    func testWhitespaceOnlyNameIsInvalid() {
        XCTAssertFalse(Person.isValidName("   "))
        XCTAssertFalse(Person.isValidName("\t"))
        XCTAssertFalse(Person.isValidName(" \n "))
    }

    func testNonEmptyNameIsValid() {
        XCTAssertTrue(Person.isValidName("Alice"))
        XCTAssertTrue(Person.isValidName(" Bob "))
    }
}

final class PersonEditPersistenceTests: XCTestCase {
    private var context: NSManagedObjectContext?

    override func setUp() {
        super.setUp()
        let controller = PersistenceController(inMemory: true)
        context = controller.container.viewContext
    }

    override func tearDown() {
        context = nil
        super.tearDown()
    }

    private func makePerson(
        name: String = "Original",
        cadence: Cadence = .monthly
    ) throws -> Person {
        let ctx = try XCTUnwrap(context)
        let person = Person(context: ctx)
        person.id = UUID()
        person.name = name
        person.cadenceRaw = cadence.rawValue
        person.createdAt = Date()
        person.updatedAt = Date()
        try ctx.save()
        return person
    }

    func testSaveWritesUpdatedValues() throws {
        let ctx = try XCTUnwrap(context)
        let person = try makePerson(name: "Original", cadence: .monthly)

        person.name = "Updated"
        person.cadence = .weekly
        person.notes = "New note"
        person.updatedAt = Date()
        try ctx.save()

        ctx.refresh(person, mergeChanges: false)

        XCTAssertEqual(person.name, "Updated")
        XCTAssertEqual(person.cadence, .weekly)
        XCTAssertEqual(person.notes, "New note")
    }

    func testCancelDoesNotPersistChanges() throws {
        let ctx = try XCTUnwrap(context)
        let person = try makePerson(name: "Original", cadence: .monthly)

        person.name = "Changed"
        person.cadence = .quarterly

        ctx.rollback()

        XCTAssertEqual(person.name, "Original")
        XCTAssertEqual(person.cadence, .monthly)
    }

    func testSaveUpdatesBirthday() throws {
        let ctx = try XCTUnwrap(context)
        let person = try makePerson()
        XCTAssertNil(person.birthday)

        let birthday = try XCTUnwrap(Calendar.current.date(from: DateComponents(year: 1990, month: 6, day: 15)))
        person.birthday = birthday
        try ctx.save()

        ctx.refresh(person, mergeChanges: false)
        XCTAssertEqual(person.birthday, birthday)
    }

    func testSaveClearsBirthdayWhenRemoved() throws {
        let ctx = try XCTUnwrap(context)
        let person = try makePerson()
        person.birthday = Date()
        try ctx.save()

        person.birthday = nil
        try ctx.save()

        ctx.refresh(person, mergeChanges: false)
        XCTAssertNil(person.birthday)
    }
}
