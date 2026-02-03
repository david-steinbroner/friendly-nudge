import Foundation

enum Cadence: String, CaseIterable, Codable {
    case weekly
    case monthly
    case quarterly
    case none

    var displayName: String {
        switch self {
        case .weekly: "Weekly"
        case .monthly: "Monthly"
        case .quarterly: "Quarterly"
        case .none: "None"
        }
    }

    var intervalDays: Int? {
        switch self {
        case .weekly: 7
        case .monthly: 30
        case .quarterly: 90
        case .none: nil
        }
    }
}
