import SwiftUI

struct SettingsView: View {
    @State private var appLockEnabled = false
    @State private var hideNotesEnabled = false
    @State private var showingExportConfirmation = false
    @State private var showingDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
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
}

#Preview {
    SettingsView()
}
