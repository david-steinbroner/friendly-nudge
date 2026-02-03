import CoreData
import SwiftUI

struct EditPersonView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var person: Person

    @State private var name: String = ""
    @State private var birthday: Date?
    @State private var hasBirthday: Bool = false
    @State private var cadence: Cadence = .none
    @State private var notes: String = ""

    private var isNameValid: Bool {
        Person.isValidName(name)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Name", text: $name)
                }

                Section("Birthday") {
                    Toggle("Birthday", isOn: $hasBirthday)
                    if hasBirthday {
                        DatePicker(
                            "Birthday",
                            selection: Binding(
                                get: { birthday ?? Date() },
                                set: { birthday = $0 }
                            ),
                            displayedComponents: .date
                        )
                    }
                }

                Section("Cadence") {
                    Picker("Cadence", selection: $cadence) {
                        ForEach(Cadence.allCases, id: \.self) { value in
                            Text(value.displayName).tag(value)
                        }
                    }
                }

                Section("Notes") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3 ... 6)
                }
            }
            .navigationTitle("Edit Person")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(!isNameValid)
                }
            }
            .onAppear {
                loadDraft()
            }
        }
    }

    private func loadDraft() {
        name = person.name ?? ""
        birthday = person.birthday
        hasBirthday = person.birthday != nil
        cadence = person.cadence
        notes = person.notes ?? ""
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
        } catch {
            // Core Data save failed - context will rollback on next fetch
        }
        dismiss()
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

    return EditPersonView(person: person)
}
