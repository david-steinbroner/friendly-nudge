import SwiftUI

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var appLockEnabled = false
    @State private var hideNotesEnabled = false
    @State private var showingDeleteConfirmation = false

    // Export state
    @State private var isExporting = false
    @State private var exportFileURL: URL?
    @State private var exportError: String?

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
                    Button {
                        performExport()
                    } label: {
                        HStack {
                            Text("Export All Data")
                            Spacer()
                            if isExporting {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isExporting)

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
            .sheet(item: $exportFileURL) { url in
                ShareSheet(activityItems: [url])
            }
            .alert("Export Failed", isPresented: .constant(exportError != nil)) {
                Button("OK") {
                    exportError = nil
                }
            } message: {
                Text(exportError ?? "An unknown error occurred.")
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

    // MARK: - Export

    private func performExport() {
        isExporting = true
        exportError = nil

        // Run on background queue to avoid blocking UI
        DispatchQueue.global(qos: .userInitiated).async {
            let result = ExportService.exportAllData(context: viewContext)

            DispatchQueue.main.async {
                isExporting = false

                switch result {
                case let .success(url):
                    exportFileURL = url
                case let .failure(error):
                    exportError = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - Share Sheet

extension URL: @retroactive Identifiable {
    public var id: String {
        absoluteString
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context _: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_: UIActivityViewController, context _: Context) {}
}

#Preview {
    SettingsView(notificationService: NotificationService())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
