import CoreData
import SwiftUI

struct AddPersonView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @State private var name: String = ""
    @State private var birthday: Date?
    @State private var hasBirthday: Bool = false
    @State private var cadence: Cadence = .none
    @State private var notes: String = ""

    private var isNameValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Name", text: $name)
                }

                Section("Birthday") {
                    Toggle("Add Birthday", isOn: $hasBirthday)
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
                        ForEach(Cadence.allCases, id: \.self) { cadence in
                            Text(cadence.displayName).tag(cadence)
                        }
                    }
                }

                Section("Notes") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3 ... 6)
                }
            }
            .navigationTitle("Add Person")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePerson()
                    }
                    .disabled(!isNameValid)
                }
            }
        }
    }

    private func savePerson() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        let newPerson = Person(context: viewContext)
        newPerson.id = UUID()
        newPerson.name = trimmedName
        newPerson.birthday = hasBirthday ? birthday : nil
        newPerson.cadence = cadence
        newPerson.notes = notes.isEmpty ? nil : notes
        newPerson.createdAt = Date()
        newPerson.updatedAt = Date()

        do {
            try viewContext.save()
            dismiss()
        } catch {
            // Core Data save failed - context will rollback on next fetch
        }
    }
}

#Preview {
    AddPersonView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
