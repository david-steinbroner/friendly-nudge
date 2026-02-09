import SwiftUI

struct SettingsView: View {
    @State private var appLockEnabled = false
    @State private var hideNotesEnabled = false
    @State private var showingExportConfirmation = false
    @State private var showingDeleteConfirmation = false

    @Bindable var notificationService: NotificationService

    var body: some View {
        NavigationStack {
            Form {
                notificationsSection

                Section("Privacy") {
                    Toggle("App Lock", isOn: $appLockEnabled)
                    Toggle("Hide Notes", isOn: $hideNotesEnabled)
                }

                Section("Data") {
                    Button("Export Data") {
                        showingExportConfirmation = true
                    }

                    Button("Delete All Data", role: .destructive) {
                        showingDeleteConfirmation = true
                    }
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .task {
                await notificationService.refreshAuthorizationStatus()
            }
            .alert("Export Data", isPresented: $showingExportConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Export") {
                    // Export functionality coming soon
                }
            } message: {
                Text("Export functionality coming soon.")
            }
            .alert("Delete All Data", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    // Delete functionality coming soon
                }
            } message: {
                Text("This will permanently delete all your data. This action cannot be undone.")
            }
        }
    }

    // MARK: - Notifications Section

    private var notificationsSection: some View {
        Section("Notifications") {
            Toggle("Daily Reminder", isOn: $notificationService.dailyReminderEnabled)
                .onChange(of: notificationService.dailyReminderEnabled) { _, newValue in
                    if newValue, notificationService.isNotDetermined {
                        Task {
                            await notificationService.requestAuthorization()
                        }
                    }
                }

            if notificationService.dailyReminderEnabled {
                DatePicker(
                    "Reminder Time",
                    selection: $notificationService.reminderTime,
                    displayedComponents: .hourAndMinute
                )
            }

            notificationStatusRow
        }
    }

    @ViewBuilder
    private var notificationStatusRow: some View {
        if notificationService.isDenied {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Notifications Disabled")
                        .font(.subheadline)
                    Text("Enable in Settings to receive reminders")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button("Open Settings") {
                    notificationService.openSettings()
                }
                .font(.subheadline)
            }
        } else if notificationService.isNotDetermined, notificationService.dailyReminderEnabled {
            Button("Enable Notifications") {
                Task {
                    await notificationService.requestAuthorization()
                }
            }
        }
    }
}

#Preview {
    SettingsView(notificationService: NotificationService())
}
