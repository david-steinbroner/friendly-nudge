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
