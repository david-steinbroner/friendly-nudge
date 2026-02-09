import CoreData
import SwiftUI

@main
struct FriendlyNudgeApp: App {
    let persistenceController = PersistenceController.shared
    @State private var notificationService = NotificationService()

    var body: some Scene {
        WindowGroup {
            ContentView(notificationService: notificationService)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .task {
                    await notificationService.syncSchedule()
                }
        }
    }
}
