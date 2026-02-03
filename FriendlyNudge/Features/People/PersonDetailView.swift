import CoreData
import SwiftUI

struct PersonDetailView: View {
    @ObservedObject var person: Person

    @State private var showingEditSheet = false
    @State private var showingLogInteraction = false
    @State private var interactionToDelete: InteractionLog?

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

            Section {
                let interactions = person.sortedInteractions
                if interactions.isEmpty {
                    Text("No interactions yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(interactions) { interaction in
                        InteractionRowView(interaction: interaction)
                    }
                    .onDelete { offsets in
                        if let index = offsets.first {
                            interactionToDelete = interactions[index]
                        }
                    }
                }
            } header: {
                HStack {
                    Text("Recent Interactions")
                    Spacer()
                    Button {
                        showingLogInteraction = true
                    } label: {
                        Label("Log Interaction", systemImage: "plus")
                            .labelStyle(.iconOnly)
                    }
                }
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
        .sheet(isPresented: $showingLogInteraction) {
            LogInteractionView(person: person)
        }
        .alert("Delete Interaction", isPresented: .init(
            get: { interactionToDelete != nil },
            set: { if !$0 { interactionToDelete = nil } }
        )) {
            Button("Cancel", role: .cancel) {
                interactionToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let interaction = interactionToDelete {
                    deleteInteraction(interaction)
                }
            }
        } message: {
            Text("Are you sure you want to delete this interaction?")
        }
    }

    @Environment(\.managedObjectContext) private var viewContext

    private func deleteInteraction(_ interaction: InteractionLog) {
        withAnimation {
            viewContext.delete(interaction)
            do {
                try viewContext.save()
            } catch {
                // Core Data save failed - context will rollback on next fetch
            }
        }
        interactionToDelete = nil
    }
}

private struct InteractionRowView: View {
    @ObservedObject var interaction: InteractionLog

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Label(
                    interaction.interactionType.displayName,
                    systemImage: interaction.interactionType.iconName
                )
                .font(.body)
                Spacer()
                if let date = interaction.date {
                    Text(date, format: .dateTime.month(.abbreviated).day().year())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            if let note = interaction.note, !note.isEmpty {
                Text(note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
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
