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
}
