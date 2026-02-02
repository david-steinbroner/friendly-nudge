import CoreData
import Foundation

@objc(InteractionLog)
public class InteractionLog: NSManagedObject {
    var interactionType: InteractionType {
        get {
            InteractionType(rawValue: typeRaw ?? "other") ?? .other
        }
        set {
            typeRaw = newValue.rawValue
        }
    }
}
