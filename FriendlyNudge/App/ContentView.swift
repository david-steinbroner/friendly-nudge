import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            PeopleListView()
                .tabItem {
                    Label("People", systemImage: "person.2")
                }

            DailyDeckView()
                .tabItem {
                    Label("Deck", systemImage: "rectangle.stack")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    ContentView()
}
