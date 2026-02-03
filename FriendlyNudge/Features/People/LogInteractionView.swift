import CoreData
import SwiftUI

struct LogInteractionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    let person: Person

    @State private var interactionType: InteractionType = .texted
    @State private var date: Date = .init()
    @State private var notes: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Type") {
                    Picker("Type", selection: $interactionType) {
                        ForEach(InteractionType.allCases, id: \.self) { type in
                            Label(type.displayName, systemImage: type.iconName)
                                .tag(type)
                        }
                    }
                }

                Section("Date") {
                    DatePicker(
                        "Date",
                        selection: $date,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }

                Section("Notes") {
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3 ... 6)
                }
            }
            .navigationTitle("Log Interaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveInteraction()
                    }
                }
            }
        }
    }

    private func saveInteraction() {
        let log = InteractionLog(context: viewContext)
        log.id = UUID()
        log.interactionType = interactionType
        log.date = date
        log.note = notes.isEmpty ? nil : notes
        log.person = person

        do {
            try viewContext.save()
            dismiss()
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

    return LogInteractionView(person: person)
        .environment(\.managedObjectContext, context)
}
