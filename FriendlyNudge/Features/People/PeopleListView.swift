import CoreData
import SwiftUI

struct PeopleListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Person.name, ascending: true)],
        animation: .default
    )
    private var people: FetchedResults<Person>

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
                    Button(action: addPerson) {
                        Label("Add Person", systemImage: "plus")
                    }
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
            Button(action: addPerson) {
                Text("Add Person")
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var peopleList: some View {
        List {
            ForEach(people) { person in
                NavigationLink(destination: PersonDetailView(person: person)) {
                    Text(person.name ?? "Unknown")
                }
            }
            .onDelete(perform: deletePeople)
        }
    }

    private func addPerson() {
        withAnimation {
            let newPerson = Person(context: viewContext)
            newPerson.id = UUID()
            newPerson.name = "New Person"
            newPerson.cadenceRaw = Cadence.none.rawValue
            newPerson.createdAt = Date()
            newPerson.updatedAt = Date()

            do {
                try viewContext.save()
            } catch {
                // Handle error appropriately in production
            }
        }
    }

    private func deletePeople(offsets: IndexSet) {
        withAnimation {
            offsets.map { people[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Handle error appropriately in production
            }
        }
    }
}

#Preview {
    PeopleListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
