import Foundation

enum InteractionType: String, CaseIterable, Codable {
    case texted
    case called
    case hungOut
    case other

    var displayName: String {
        switch self {
        case .texted: return "Texted"
        case .called: return "Called"
        case .hungOut: return "Hung Out"
        case .other: return "Other"
        }
    }

    var iconName: String {
        switch self {
        case .texted: return "message"
        case .called: return "phone"
        case .hungOut: return "person.2"
        case .other: return "ellipsis.circle"
        }
    }
}
