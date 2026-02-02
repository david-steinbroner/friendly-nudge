import SwiftUI

struct DailyDeckView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView {
                Label("Your Daily Deck", systemImage: "rectangle.stack")
            } description: {
                Text("People you should reach out to today will appear here.")
            }
            .navigationTitle("Deck")
        }
    }
}

#Preview {
    DailyDeckView()
}
