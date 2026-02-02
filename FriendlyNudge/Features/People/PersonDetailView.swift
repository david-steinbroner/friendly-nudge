import SwiftUI
import CoreData

struct PersonDetailView: View {
    @ObservedObject var person: Person

    var body: some View {
        Form {
            Section("Details") {
                Text(person.name ?? "Unknown")
            }

            Section("Cadence") {
                Text(person.cadence.displayName)
            }

            if let lastConnected = person.lastConnectedDate {
                Section("Last Connected") {
                    Text(lastConnected, style: .date)
                }
            }

            Section("Interactions") {
                Text("Interaction logging coming soon")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(person.name ?? "Person")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let person = Person(context: context)
    person.id = UUID()
    person.name = "Preview Person"
    person.cadenceRaw = Cadence.monthly.rawValue
    person.createdAt = Date()
    person.updatedAt = Date()

    return NavigationStack {
        PersonDetailView(person: person)
    }
}
