import Foundation

enum Cadence: String, CaseIterable, Codable {
    case weekly
    case monthly
    case quarterly
    case none

    var displayName: String {
        switch self {
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .quarterly: return "Quarterly"
        case .none: return "None"
        }
    }
}
