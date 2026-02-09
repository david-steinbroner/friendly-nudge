import SwiftUI

struct ContentView: View {
    @Bindable var notificationService: NotificationService

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

            SettingsView(notificationService: notificationService)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    ContentView(notificationService: NotificationService())
}
