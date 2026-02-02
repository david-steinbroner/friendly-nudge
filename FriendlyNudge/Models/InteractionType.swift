import Foundation

enum InteractionType: String, CaseIterable, Codable {
    case texted
    case called
    case hungOut
    case other

    var displayName: String {
        switch self {
        case .texted: "Texted"
        case .called: "Called"
        case .hungOut: "Hung Out"
        case .other: "Other"
        }
    }

    var iconName: String {
        switch self {
        case .texted: "message"
        case .called: "phone"
        case .hungOut: "person.2"
        case .other: "ellipsis.circle"
        }
    }
}
