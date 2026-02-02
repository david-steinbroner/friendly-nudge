import CoreData
import Foundation

@objc(Person)
public class Person: NSManagedObject {
    var cadence: Cadence {
        get {
            Cadence(rawValue: cadenceRaw ?? "none") ?? .none
        }
        set {
            cadenceRaw = newValue.rawValue
        }
    }
}
