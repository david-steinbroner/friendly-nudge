import CoreData
import SwiftUI

struct PeopleListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Person.name, ascending: true)],
        animation: .default
    )
    private var people: FetchedResults<Person>

    @State private var showingAddPerson = false
    @State private var personToDelete: Person?

    var body: some View {
        NavigationStack {
            Group {
                if people.isEmpty {
                    emptyStateView
                } else {
                    peopleList
                }
            }
            .navigationTitle("People")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddPerson = true
                    } label: {
                        Label("Add Person", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPerson) {
                AddPersonView()
            }
            .alert("Delete Person", isPresented: .init(
                get: { personToDelete != nil },
                set: { if !$0 { personToDelete = nil } }
            )) {
                Button("Cancel", role: .cancel) {
                    personToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let person = personToDelete {
                        deletePerson(person)
                    }
                }
            } message: {
                if let person = personToDelete {
                    Text("Are you sure you want to delete \(person.name ?? "this person")?")
                }
            }
        }
    }

    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No People Yet", systemImage: "person.2")
        } description: {
            Text("Add people you want to stay in touch with.")
        } actions: {
            Button("Add Person") {
                showingAddPerson = true
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var peopleList: some View {
        List {
            ForEach(people) { person in
                NavigationLink(destination: PersonDetailView(person: person)) {
                    PersonRowView(person: person)
                }
            }
            .onDelete(perform: confirmDelete)
        }
    }

    private func confirmDelete(offsets: IndexSet) {
        if let index = offsets.first {
            personToDelete = people[index]
        }
    }

    private func deletePerson(_ person: Person) {
        withAnimation {
            viewContext.delete(person)
            do {
                try viewContext.save()
            } catch {
                // Core Data save failed - context will rollback on next fetch
            }
        }
        personToDelete = nil
    }
}

private struct PersonRowView: View {
    @ObservedObject var person: Person

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(person.name ?? "Unknown")
            Text(person.cadence.displayName)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    PeopleListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
