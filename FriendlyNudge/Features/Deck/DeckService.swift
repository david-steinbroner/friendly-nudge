import CryptoKit
import Foundation

enum DeckService {
    static let defaultDeckSize = 7

    /// Selects people for today's deck using deterministic, cadence-based scoring.
    ///
    /// Rules:
    /// 1. Exclude people whose cadence is `.none`.
    /// 2. Exclude people snoozed past `referenceDate`.
    /// 3. Score each person by how overdue they are: `daysSinceContact / cadenceInterval`.
    /// 4. Sort descending by score; break ties deterministically using a day-seeded hash.
    /// 5. Return the top `deckSize` results.
    static func selectDeck(
        from people: [Person],
        on referenceDate: Date,
        calendar: Calendar = .current,
        deckSize: Int = defaultDeckSize
    ) -> [Person] {
        let startOfDay = calendar.startOfDay(for: referenceDate)

        let eligible = people.filter { person in
            guard person.cadence != .none else { return false }

            if let snoozeUntil = person.snoozeUntil, snoozeUntil > startOfDay {
                return false
            }

            return true
        }

        let scored: [(person: Person, score: Double, tieBreaker: UInt64)] = eligible.map { person in
            let score = urgencyScore(for: person, on: startOfDay, calendar: calendar)
            let tieBreaker = deterministicHash(personID: person.id, day: startOfDay)
            return (person, score, tieBreaker)
        }

        let sorted = scored.sorted { lhs, rhs in
            if lhs.score != rhs.score {
                return lhs.score > rhs.score
            }
            return lhs.tieBreaker < rhs.tieBreaker
        }

        return Array(sorted.prefix(deckSize).map(\.person))
    }

    static func urgencyScore(
        for person: Person,
        on startOfDay: Date,
        calendar: Calendar
    ) -> Double {
        guard let intervalDays = person.cadence.intervalDays, intervalDays > 0 else {
            return 0
        }

        let lastContact = person.lastConnectedDate ?? person.createdAt ?? startOfDay
        let daysSince = max(0, calendar.dateComponents([.day], from: lastContact, to: startOfDay).day ?? 0)

        return Double(daysSince) / Double(intervalDays)
    }

    static func deterministicHash(personID: UUID?, day: Date) -> UInt64 {
        let idString = personID?.uuidString ?? ""
        let dayInterval = Int(day.timeIntervalSinceReferenceDate)
        let input = "\(idString)-\(dayInterval)"
        let digest = SHA256.hash(data: Data(input.utf8))
        return digest.withUnsafeBytes { bytes in
            bytes.load(as: UInt64.self)
        }
    }
}
