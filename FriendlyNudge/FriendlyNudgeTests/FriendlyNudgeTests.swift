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

// MARK: - Interaction Log Tests (SKU-362)

final class InteractionLogPersistenceTests: XCTestCase {
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

    private func makePerson(name: String = "Test Person") throws -> Person {
        let ctx = try XCTUnwrap(context)
        let person = Person(context: ctx)
        person.id = UUID()
        person.name = name
        person.cadenceRaw = Cadence.monthly.rawValue
        person.createdAt = Date()
        person.updatedAt = Date()
        try ctx.save()
        return person
    }

    private func makeInteraction(
        person: Person,
        type: InteractionType = .texted,
        date: Date = Date(),
        note: String? = nil
    ) throws -> InteractionLog {
        let ctx = try XCTUnwrap(context)
        let log = InteractionLog(context: ctx)
        log.id = UUID()
        log.interactionType = type
        log.date = date
        log.note = note
        log.person = person
        try ctx.save()
        return log
    }

    func testCreateInteractionLogPersistsAndLinksToP() throws {
        let ctx = try XCTUnwrap(context)
        let person = try makePerson()
        let log = try makeInteraction(person: person, type: .called, note: "Quick check-in")

        ctx.refresh(log, mergeChanges: false)
        ctx.refresh(person, mergeChanges: false)

        XCTAssertEqual(log.interactionType, .called)
        XCTAssertEqual(log.note, "Quick check-in")
        XCTAssertEqual(log.person, person)
        XCTAssertNotNil(log.id)

        let logs = person.interactionLogs as? Set<InteractionLog> ?? []
        XCTAssertTrue(logs.contains(log))
    }

    func testInteractionsSortDescendingByTimestamp() throws {
        let person = try makePerson()
        let now = Date()
        let older = now.addingTimeInterval(-3600)
        let oldest = now.addingTimeInterval(-7200)

        _ = try makeInteraction(person: person, type: .texted, date: oldest)
        _ = try makeInteraction(person: person, type: .called, date: now)
        _ = try makeInteraction(person: person, type: .hungOut, date: older)

        let sorted = person.sortedInteractions
        XCTAssertEqual(sorted.count, 3)
        XCTAssertEqual(sorted[0].interactionType, .called)
        XCTAssertEqual(sorted[1].interactionType, .hungOut)
        XCTAssertEqual(sorted[2].interactionType, .texted)
    }

    func testDeleteInteractionRemovesRecord() throws {
        let ctx = try XCTUnwrap(context)
        let person = try makePerson()
        let log = try makeInteraction(person: person, type: .texted)

        XCTAssertEqual(person.sortedInteractions.count, 1)

        ctx.delete(log)
        try ctx.save()

        ctx.refresh(person, mergeChanges: false)
        XCTAssertEqual(person.sortedInteractions.count, 0)
    }

    func testInteractionTypeRoundTrips() throws {
        let person = try makePerson()

        for type in InteractionType.allCases {
            let log = try makeInteraction(person: person, type: type)
            XCTAssertEqual(log.interactionType, type)
            XCTAssertEqual(log.typeRaw, type.rawValue)
        }
    }
}

// MARK: - Cadence Interval Days Tests (SKU-363)

final class CadenceIntervalDaysTests: XCTestCase {
    func testIntervalDaysValues() {
        XCTAssertEqual(Cadence.weekly.intervalDays, 7)
        XCTAssertEqual(Cadence.monthly.intervalDays, 30)
        XCTAssertEqual(Cadence.quarterly.intervalDays, 90)
        XCTAssertNil(Cadence.none.intervalDays)
    }
}

// MARK: - DeckService Tests (SKU-363)

final class DeckServiceTests: XCTestCase {
    private var context: NSManagedObjectContext?
    private var calendar: Calendar?

    /// Fixed reference date: 2025-06-15 00:00:00 UTC
    private var referenceDate: Date?

    override func setUp() {
        super.setUp()
        let controller = PersistenceController(inMemory: true)
        context = controller.container.viewContext

        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC") ?? .current
        calendar = cal

        referenceDate = cal.date(from: DateComponents(year: 2025, month: 6, day: 15))
    }

    override func tearDown() {
        context = nil
        calendar = nil
        referenceDate = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private func ctx() throws -> NSManagedObjectContext {
        try XCTUnwrap(context)
    }

    private func cal() throws -> Calendar {
        try XCTUnwrap(calendar)
    }

    private func refDate() throws -> Date {
        try XCTUnwrap(referenceDate)
    }

    @discardableResult
    private func makePerson(
        name: String,
        cadence: Cadence = .weekly,
        lastConnected: Date? = nil,
        snoozeUntil: Date? = nil,
        createdAt: Date? = nil
    ) throws -> Person {
        let c = try ctx()
        let r = try refDate()
        let person = Person(context: c)
        person.id = UUID()
        person.name = name
        person.cadenceRaw = cadence.rawValue
        person.lastConnectedDate = lastConnected
        person.snoozeUntil = snoozeUntil
        person.createdAt = createdAt ?? r.addingTimeInterval(-86400 * 30)
        person.updatedAt = person.createdAt
        return person
    }

    private func daysAgo(_ days: Int) throws -> Date {
        let c = try cal()
        let r = try refDate()
        return try XCTUnwrap(c.date(byAdding: .day, value: -days, to: r))
    }

    private func daysFromNow(_ days: Int) throws -> Date {
        let c = try cal()
        let r = try refDate()
        return try XCTUnwrap(c.date(byAdding: .day, value: days, to: r))
    }

    // MARK: - Empty / Small Datasets

    func testEmptyPeopleReturnsEmptyDeck() throws {
        let deck = try DeckService.selectDeck(from: [], on: refDate(), calendar: cal())
        XCTAssertTrue(deck.isEmpty)
    }

    func testSingleEligiblePersonReturnsThatPerson() throws {
        let alice = try makePerson(name: "Alice", cadence: .weekly, lastConnected: daysAgo(10))
        let deck = try DeckService.selectDeck(from: [alice], on: refDate(), calendar: cal())
        XCTAssertEqual(deck.count, 1)
        XCTAssertEqual(deck.first?.name, "Alice")
    }

    func testFewerPeopleThanDeckSizeReturnsAll() throws {
        let alice = try makePerson(name: "Alice", cadence: .weekly, lastConnected: daysAgo(10))
        let bob = try makePerson(name: "Bob", cadence: .monthly, lastConnected: daysAgo(40))
        let carol = try makePerson(name: "Carol", cadence: .quarterly, lastConnected: daysAgo(100))

        let deck = try DeckService.selectDeck(
            from: [alice, bob, carol],
            on: refDate(),
            calendar: cal(),
            deckSize: 7
        )
        XCTAssertEqual(deck.count, 3)
    }

    // MARK: - Filtering: Cadence None

    func testCadenceNoneExcluded() throws {
        let alice = try makePerson(name: "Alice", cadence: .weekly, lastConnected: daysAgo(10))
        _ = try makePerson(name: "Bob", cadence: .none)

        let deck = try DeckService.selectDeck(from: [alice], on: refDate(), calendar: cal())
        XCTAssertEqual(deck.count, 1)
        XCTAssertEqual(deck.first?.name, "Alice")
    }

    func testAllCadenceNoneReturnsEmpty() throws {
        let alice = try makePerson(name: "Alice", cadence: .none)
        let bob = try makePerson(name: "Bob", cadence: .none)

        let deck = try DeckService.selectDeck(from: [alice, bob], on: refDate(), calendar: cal())
        XCTAssertTrue(deck.isEmpty)
    }

    // MARK: - Filtering: Snooze

    func testSnoozedPersonExcluded() throws {
        let alice = try makePerson(name: "Alice", cadence: .weekly, lastConnected: daysAgo(10))
        let bob = try makePerson(
            name: "Bob",
            cadence: .weekly,
            lastConnected: daysAgo(10),
            snoozeUntil: daysFromNow(3)
        )

        let deck = try DeckService.selectDeck(from: [alice, bob], on: refDate(), calendar: cal())
        XCTAssertEqual(deck.count, 1)
        XCTAssertEqual(deck.first?.name, "Alice")
    }

    func testExpiredSnoozeIncluded() throws {
        let alice = try makePerson(
            name: "Alice",
            cadence: .weekly,
            lastConnected: daysAgo(10),
            snoozeUntil: daysAgo(1)
        )

        let deck = try DeckService.selectDeck(from: [alice], on: refDate(), calendar: cal())
        XCTAssertEqual(deck.count, 1)
        XCTAssertEqual(deck.first?.name, "Alice")
    }

    func testSnoozeExpiringTodayIncluded() throws {
        let c = try cal()
        let r = try refDate()
        let startOfDay = c.startOfDay(for: r)
        let alice = try makePerson(
            name: "Alice",
            cadence: .weekly,
            lastConnected: daysAgo(10),
            snoozeUntil: startOfDay
        )

        let deck = DeckService.selectDeck(from: [alice], on: r, calendar: c)
        XCTAssertEqual(deck.count, 1)
    }

    // MARK: - Determinism

    func testSameInputsSameDayProducesSameResult() throws {
        let people = try (1 ... 20).map { i in
            try makePerson(
                name: "Person \(i)",
                cadence: .weekly,
                lastConnected: daysAgo(i)
            )
        }

        let r = try refDate()
        let c = try cal()
        let deck1 = DeckService.selectDeck(from: people, on: r, calendar: c)
        let deck2 = DeckService.selectDeck(from: people, on: r, calendar: c)

        XCTAssertEqual(deck1.map(\.id), deck2.map(\.id))
    }

    func testDeterminismAcrossInputOrder() throws {
        let alice = try makePerson(name: "Alice", cadence: .weekly, lastConnected: daysAgo(5))
        let bob = try makePerson(name: "Bob", cadence: .weekly, lastConnected: daysAgo(5))
        let carol = try makePerson(name: "Carol", cadence: .weekly, lastConnected: daysAgo(5))

        let r = try refDate()
        let c = try cal()
        let deck1 = DeckService.selectDeck(from: [alice, bob, carol], on: r, calendar: c)
        let deck2 = DeckService.selectDeck(from: [carol, alice, bob], on: r, calendar: c)

        XCTAssertEqual(deck1.map(\.id), deck2.map(\.id))
    }

    // MARK: - Day Change

    func testDifferentDayChangeTieBreaking() throws {
        let people = try (1 ... 10).map { i in
            try makePerson(
                name: "Person \(i)",
                cadence: .weekly,
                lastConnected: daysAgo(7)
            )
        }

        let day1 = try refDate()
        let day2 = try daysFromNow(1)
        let c = try cal()

        let deck1 = DeckService.selectDeck(from: people, on: day1, calendar: c, deckSize: 3)
        let deck2 = DeckService.selectDeck(from: people, on: day2, calendar: c, deckSize: 3)

        let ids1 = deck1.map(\.id)
        let ids2 = deck2.map(\.id)
        XCTAssertNotEqual(ids1, ids2, "Tie-breaking order should change across days")
    }

    // MARK: - Urgency Scoring

    func testMoreOverduePersonRankedHigher() throws {
        let veryOverdue = try makePerson(name: "Very Overdue", cadence: .weekly, lastConnected: daysAgo(30))
        let slightlyOverdue = try makePerson(name: "Slightly Overdue", cadence: .weekly, lastConnected: daysAgo(8))
        let notOverdue = try makePerson(name: "Not Overdue", cadence: .weekly, lastConnected: daysAgo(3))

        let deck = try DeckService.selectDeck(
            from: [notOverdue, slightlyOverdue, veryOverdue],
            on: refDate(),
            calendar: cal(),
            deckSize: 3
        )

        XCTAssertEqual(deck[0].name, "Very Overdue")
        XCTAssertEqual(deck[1].name, "Slightly Overdue")
        XCTAssertEqual(deck[2].name, "Not Overdue")
    }

    func testUrgencyScoreCalculation() throws {
        let c = try cal()
        let r = try refDate()
        let person = try makePerson(name: "Test", cadence: .weekly, lastConnected: daysAgo(14))
        let startOfDay = c.startOfDay(for: r)
        let score = DeckService.urgencyScore(for: person, on: startOfDay, calendar: c)
        XCTAssertEqual(score, 2.0, accuracy: 0.01)
    }

    func testUrgencyScoreMonthly() throws {
        let c = try cal()
        let r = try refDate()
        let person = try makePerson(name: "Test", cadence: .monthly, lastConnected: daysAgo(60))
        let startOfDay = c.startOfDay(for: r)
        let score = DeckService.urgencyScore(for: person, on: startOfDay, calendar: c)
        XCTAssertEqual(score, 2.0, accuracy: 0.01)
    }

    func testUrgencyScoreNeverContactedUsesCreatedAt() throws {
        let c = try cal()
        let r = try refDate()
        let person = try makePerson(
            name: "New Friend",
            cadence: .weekly,
            lastConnected: nil,
            createdAt: daysAgo(20)
        )
        let startOfDay = c.startOfDay(for: r)
        let score = DeckService.urgencyScore(for: person, on: startOfDay, calendar: c)
        XCTAssertEqual(score, 20.0 / 7.0, accuracy: 0.01)
    }

    func testUrgencyScoreCadenceNoneReturnsZero() throws {
        let c = try cal()
        let r = try refDate()
        let person = try makePerson(name: "Test", cadence: .none)
        let startOfDay = c.startOfDay(for: r)
        let score = DeckService.urgencyScore(for: person, on: startOfDay, calendar: c)
        XCTAssertEqual(score, 0.0)
    }

    // MARK: - Deck Size

    func testDeckSizeLimitsResults() throws {
        let people = try (1 ... 20).map { i in
            try makePerson(name: "Person \(i)", cadence: .weekly, lastConnected: daysAgo(i + 7))
        }

        let deck = try DeckService.selectDeck(
            from: people,
            on: refDate(),
            calendar: cal(),
            deckSize: 5
        )
        XCTAssertEqual(deck.count, 5)
    }

    func testDefaultDeckSizeIsSeven() {
        XCTAssertEqual(DeckService.defaultDeckSize, 7)
    }

    // MARK: - Stability / Ordering

    func testStableOrderingPreservedAcrossRepeatedCalls() throws {
        let people = try (1 ... 15).map { i in
            try makePerson(name: "Person \(i)", cadence: .weekly, lastConnected: daysAgo(i * 2))
        }

        let r = try refDate()
        let c = try cal()
        var results: [[UUID?]] = []
        for _ in 0 ..< 5 {
            let deck = DeckService.selectDeck(
                from: people.shuffled(),
                on: r,
                calendar: c,
                deckSize: 7
            )
            results.append(deck.map(\.id))
        }

        for i in 1 ..< results.count {
            XCTAssertEqual(results[0], results[i], "Run \(i) produced different ordering")
        }
    }

    // MARK: - Fairness / Rotation

    func testFairnessOverMultipleDays() throws {
        let people = try (1 ... 14).map { i in
            try makePerson(
                name: "Person \(i)",
                cadence: .weekly,
                lastConnected: daysAgo(7)
            )
        }

        let c = try cal()
        let r = try refDate()
        var appearances: [UUID: Int] = [:]
        for dayOffset in 0 ..< 14 {
            let day = try XCTUnwrap(c.date(byAdding: .day, value: dayOffset, to: r))
            let deck = DeckService.selectDeck(
                from: people,
                on: day,
                calendar: c,
                deckSize: 7
            )
            for person in deck {
                let personID = try XCTUnwrap(person.id)
                appearances[personID, default: 0] += 1
            }
        }

        for person in people {
            let personID = try XCTUnwrap(person.id)
            let personName = person.name ?? "Unknown"
            let count = appearances[personID] ?? 0
            XCTAssertGreaterThan(count, 0, "\(personName) never appeared in 14 days")
        }
    }

    func testHigherCadencePrioritizedOverLower() throws {
        let weeklyOverdue = try makePerson(
            name: "Weekly Overdue",
            cadence: .weekly,
            lastConnected: daysAgo(14)
        )
        let monthlyOnTime = try makePerson(
            name: "Monthly On-Time",
            cadence: .monthly,
            lastConnected: daysAgo(30)
        )

        let deck = try DeckService.selectDeck(
            from: [monthlyOnTime, weeklyOverdue],
            on: refDate(),
            calendar: cal()
        )

        XCTAssertEqual(deck.first?.name, "Weekly Overdue")
    }

    // MARK: - Mixed Scenarios

    func testMixedCadenceAndSnooze() throws {
        let alice = try makePerson(name: "Alice", cadence: .weekly, lastConnected: daysAgo(14))
        let bob = try makePerson(name: "Bob", cadence: .none)
        let carol = try makePerson(
            name: "Carol",
            cadence: .monthly,
            lastConnected: daysAgo(60),
            snoozeUntil: daysFromNow(5)
        )
        let dave = try makePerson(name: "Dave", cadence: .quarterly, lastConnected: daysAgo(180))

        let deck = try DeckService.selectDeck(
            from: [alice, bob, carol, dave],
            on: refDate(),
            calendar: cal()
        )

        let names = deck.compactMap(\.name)
        XCTAssertEqual(deck.count, 2)
        XCTAssertTrue(names.contains("Alice"))
        XCTAssertTrue(names.contains("Dave"))
        XCTAssertFalse(names.contains("Bob"))
        XCTAssertFalse(names.contains("Carol"))
    }

    func testRecentlyContactedPersonRankedLower() throws {
        let r = try refDate()
        let justContacted = try makePerson(
            name: "Just Contacted",
            cadence: .weekly,
            lastConnected: r
        )
        let overdue = try makePerson(
            name: "Overdue",
            cadence: .weekly,
            lastConnected: daysAgo(14)
        )

        let deck = try DeckService.selectDeck(
            from: [justContacted, overdue],
            on: r,
            calendar: cal()
        )

        XCTAssertEqual(deck[0].name, "Overdue")
        XCTAssertEqual(deck[1].name, "Just Contacted")
    }

    // MARK: - Deterministic Hash

    func testDeterministicHashConsistent() throws {
        let c = try cal()
        let r = try refDate()
        let id = UUID()
        let day = c.startOfDay(for: r)
        let h1 = DeckService.deterministicHash(personID: id, day: day)
        let h2 = DeckService.deterministicHash(personID: id, day: day)
        XCTAssertEqual(h1, h2)
    }

    func testDeterministicHashDiffersForDifferentDays() throws {
        let c = try cal()
        let r = try refDate()
        let id = UUID()
        let day1 = c.startOfDay(for: r)
        let day2 = try c.startOfDay(for: daysFromNow(1))
        let h1 = DeckService.deterministicHash(personID: id, day: day1)
        let h2 = DeckService.deterministicHash(personID: id, day: day2)
        XCTAssertNotEqual(h1, h2)
    }

    func testDeterministicHashDiffersForDifferentPeople() throws {
        let c = try cal()
        let r = try refDate()
        let day = c.startOfDay(for: r)
        let h1 = DeckService.deterministicHash(personID: UUID(), day: day)
        let h2 = DeckService.deterministicHash(personID: UUID(), day: day)
        XCTAssertNotEqual(h1, h2)
    }
}

// MARK: - Notification Scheduler Tests (SKU-364)

final class NotificationSchedulerTests: XCTestCase {
    private var mockClient: MockNotificationCenterClient?

    override func setUp() {
        super.setUp()
        mockClient = MockNotificationCenterClient()
    }

    override func tearDown() {
        mockClient = nil
        super.tearDown()
    }

    private func client() throws -> MockNotificationCenterClient {
        try XCTUnwrap(mockClient)
    }

    // MARK: - Scheduling When Enabled + Authorized

    func testEnabledAndAuthorizedSchedulesDailyNudge() async throws {
        let c = try client()
        c.mockAuthorizationStatus = .authorized

        let result = try await NotificationScheduler.sync(
            enabled: true,
            hour: 9,
            minute: 30,
            authorizationStatus: .authorized,
            client: c
        )

        XCTAssertEqual(result, .scheduled(hour: 9, minute: 30))
        XCTAssertEqual(c.addedRequests.count, 1)

        let request = try XCTUnwrap(c.addedRequests.first)
        XCTAssertEqual(request.identifier, NotificationIdentifier.dailyNudge)

        let trigger = try XCTUnwrap(request.trigger as? UNCalendarNotificationTrigger)
        XCTAssertEqual(trigger.dateComponents.hour, 9)
        XCTAssertEqual(trigger.dateComponents.minute, 30)
        XCTAssertTrue(trigger.repeats)

        XCTAssertEqual(request.content.title, "Friendly nudge")
        XCTAssertEqual(request.content.body, "Check in with someone you care about.")
    }

    func testSchedulingRemovesExistingNotificationsFirst() async throws {
        let c = try client()
        c.mockAuthorizationStatus = .authorized

        _ = try await NotificationScheduler.sync(
            enabled: true,
            hour: 9,
            minute: 0,
            authorizationStatus: .authorized,
            client: c
        )

        XCTAssertTrue(c.removedPendingIdentifiers.contains(NotificationIdentifier.dailyNudge))
        XCTAssertTrue(c.removedDeliveredIdentifiers.contains(NotificationIdentifier.dailyNudge))
    }

    // MARK: - Disabled

    func testDisabledCancelsNotifications() async throws {
        let c = try client()
        let result = try await NotificationScheduler.sync(
            enabled: false,
            hour: 9,
            minute: 0,
            authorizationStatus: .authorized,
            client: c
        )

        XCTAssertEqual(result, .disabled)
        XCTAssertTrue(c.addedRequests.isEmpty)
        XCTAssertTrue(c.removedPendingIdentifiers.contains(NotificationIdentifier.dailyNudge))
        XCTAssertTrue(c.removedDeliveredIdentifiers.contains(NotificationIdentifier.dailyNudge))
    }

    // MARK: - Not Authorized

    func testNotAuthorizedDoesNotSchedule() async throws {
        let c = try client()
        let result = try await NotificationScheduler.sync(
            enabled: true,
            hour: 9,
            minute: 0,
            authorizationStatus: .denied,
            client: c
        )

        XCTAssertEqual(result, .notAuthorized)
        XCTAssertTrue(c.addedRequests.isEmpty)
    }

    func testNotDeterminedDoesNotSchedule() async throws {
        let c = try client()
        let result = try await NotificationScheduler.sync(
            enabled: true,
            hour: 9,
            minute: 0,
            authorizationStatus: .notDetermined,
            client: c
        )

        XCTAssertEqual(result, .notAuthorized)
        XCTAssertTrue(c.addedRequests.isEmpty)
    }

    // MARK: - Time Changes

    func testChangingTimeReschedulesWithNewTime() async throws {
        let c = try client()
        c.mockAuthorizationStatus = .authorized

        // Schedule at 9:00
        _ = try await NotificationScheduler.sync(
            enabled: true,
            hour: 9,
            minute: 0,
            authorizationStatus: .authorized,
            client: c
        )

        // Clear tracking
        c.addedRequests = []
        c.removedPendingIdentifiers = []

        // Reschedule at 14:30
        let result = try await NotificationScheduler.sync(
            enabled: true,
            hour: 14,
            minute: 30,
            authorizationStatus: .authorized,
            client: c
        )

        XCTAssertEqual(result, .scheduled(hour: 14, minute: 30))
        XCTAssertTrue(c.removedPendingIdentifiers.contains(NotificationIdentifier.dailyNudge))
        XCTAssertEqual(c.addedRequests.count, 1)

        let request = try XCTUnwrap(c.addedRequests.first)
        let trigger = try XCTUnwrap(request.trigger as? UNCalendarNotificationTrigger)
        XCTAssertEqual(trigger.dateComponents.hour, 14)
        XCTAssertEqual(trigger.dateComponents.minute, 30)
    }

    // MARK: - Cancel

    func testCancelRemovesPendingAndDelivered() throws {
        let c = try client()
        NotificationScheduler.cancel(client: c)

        XCTAssertTrue(c.removedPendingIdentifiers.contains(NotificationIdentifier.dailyNudge))
        XCTAssertTrue(c.removedDeliveredIdentifiers.contains(NotificationIdentifier.dailyNudge))
    }

    // MARK: - Trigger Components

    func testTriggerComponentsCreatesCorrectDateComponents() {
        let components = NotificationScheduler.triggerComponents(hour: 15, minute: 45)

        XCTAssertEqual(components.hour, 15)
        XCTAssertEqual(components.minute, 45)
    }

    // MARK: - Notification Identifier

    func testNotificationIdentifierIsStable() {
        XCTAssertEqual(NotificationIdentifier.dailyNudge, "dailyNudge")
    }
}
