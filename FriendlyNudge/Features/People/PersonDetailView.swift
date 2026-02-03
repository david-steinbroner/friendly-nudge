import CoreData
import SwiftUI

struct PersonDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var person: Person

    @State private var name: String = ""
    @State private var birthday: Date?
    @State private var hasBirthday: Bool = false
    @State private var cadence: Cadence = .none
    @State private var notes: String = ""

    @State private var hasChanges = false

    private var isNameValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        Form {
            Section("Name") {
                TextField("Name", text: $name)
                    .onChange(of: name) { hasChanges = true }
            }

            Section("Birthday") {
                Toggle("Birthday", isOn: $hasBirthday)
                    .onChange(of: hasBirthday) { hasChanges = true }
                if hasBirthday {
                    DatePicker(
                        "Birthday",
                        selection: Binding(
                            get: { birthday ?? Date() },
                            set: {
                                birthday = $0
                                hasChanges = true
                            }
                        ),
                        displayedComponents: .date
                    )
                }
            }

            Section("Cadence") {
                Picker("Cadence", selection: $cadence) {
                    ForEach(Cadence.allCases, id: \.self) { cadence in
                        Text(cadence.displayName).tag(cadence)
                    }
                }
                .onChange(of: cadence) { hasChanges = true }
            }

            Section("Notes") {
                TextField("Notes", text: $notes, axis: .vertical)
                    .lineLimit(3 ... 6)
                    .onChange(of: notes) { hasChanges = true }
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
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveChanges()
                }
                .disabled(!hasChanges || !isNameValid)
            }
        }
        .onAppear {
            loadPersonData()
        }
    }

    private func loadPersonData() {
        name = person.name ?? ""
        birthday = person.birthday
        hasBirthday = person.birthday != nil
        cadence = person.cadence
        notes = person.notes ?? ""
        hasChanges = false
    }

    private func saveChanges() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        person.name = trimmedName
        person.birthday = hasBirthday ? birthday : nil
        person.cadence = cadence
        person.notes = notes.isEmpty ? nil : notes
        person.updatedAt = Date()

        do {
            try viewContext.save()
            hasChanges = false
        } catch {
            // Core Data save failed - context will rollback on next fetch
        }
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
