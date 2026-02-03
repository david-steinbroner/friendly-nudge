import CoreData
import SwiftUI

struct PersonDetailView: View {
    @ObservedObject var person: Person

    @State private var showingEditSheet = false

    var body: some View {
        Form {
            Section("Name") {
                Text(person.name ?? "Unknown")
            }

            if let birthday = person.birthday {
                Section("Birthday") {
                    Text(birthday, style: .date)
                }
            }

            Section("Cadence") {
                Text(person.cadence.displayName)
            }

            if let notes = person.notes, !notes.isEmpty {
                Section("Notes") {
                    Text(notes)
                }
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
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditPersonView(person: person)
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let person = Person(context: context)
    person.id = UUID()
    person.name = "Preview Person"
    person.cadenceRaw = Cadence.monthly.rawValue
    person.birthday = Calendar.current.date(from: DateComponents(year: 1990, month: 6, day: 15))
    person.notes = "Old college friend"
    person.createdAt = Date()
    person.updatedAt = Date()

    return NavigationStack {
        PersonDetailView(person: person)
    }
}
