import SwiftUI

struct ManualEntryForm: View {
    let projects: [Project]
    let onSave: (Date, Date, String, Project?) -> Void
    let onCancel: () -> Void
    let onDetectOverlaps: (Date, Date) -> [TimeEntry]

    @State private var startTime: Date = Date().addingTimeInterval(-3600)
    @State private var endTime: Date = Date()
    @State private var taskDescription: String = ""
    @State private var selectedProjectId: UUID?
    @State private var showOverlapWarning: Bool = false
    @State private var pendingSave: Bool = false

    private var validationError: String? {
        if startTime >= endTime {
            return "End time must be after start time."
        }
        return nil
    }

    private var selectedProject: Project? {
        projects.first { $0.id == selectedProjectId }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            Text("Add time entry")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(TogglTheme.textPrimary)

            Rectangle()
                .fill(TogglTheme.divider)
                .frame(height: 1)

            // Task description
            VStack(alignment: .leading, spacing: 6) {
                Text("DESCRIPTION")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(TogglTheme.textTertiary)
                    .tracking(0.8)
                TextField("What did you work on?", text: $taskDescription)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                    .foregroundStyle(TogglTheme.textPrimary)
                    .togglInput()
            }

            // Time pickers
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("START")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(TogglTheme.textTertiary)
                            .tracking(0.8)
                        DatePicker("", selection: $startTime, displayedComponents: [.date, .hourAndMinute])
                            .labelsHidden()
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("END")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(TogglTheme.textTertiary)
                            .tracking(0.8)
                        DatePicker("", selection: $endTime, displayedComponents: [.date, .hourAndMinute])
                            .labelsHidden()
                    }
                }
            }

            if let error = validationError {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 10))
                    Text(error)
                        .font(.system(size: 11))
                }
                .foregroundStyle(TogglTheme.accentRed)
            }

            // Project picker
            VStack(alignment: .leading, spacing: 6) {
                Text("PROJECT")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(TogglTheme.textTertiary)
                    .tracking(0.8)
                Picker("", selection: $selectedProjectId) {
                    Text("No project").tag(nil as UUID?)
                    ForEach(projects) { project in
                        HStack {
                            Circle()
                                .fill(Color(hex: project.colorHex))
                                .frame(width: 8, height: 8)
                            Text(project.name)
                        }
                        .tag(project.id as UUID?)
                    }
                }
                .labelsHidden()
            }

            Rectangle()
                .fill(TogglTheme.divider)
                .frame(height: 1)

            // Actions
            HStack {
                Button("Cancel") {
                    onCancel()
                }
                .keyboardShortcut(.escape, modifiers: [])
                .foregroundStyle(TogglTheme.textSecondary)

                Spacer()

                Button(action: { attemptSave() }) {
                    Text("Save")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(TogglTheme.accentPink)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.return, modifiers: .command)
                .disabled(validationError != nil)
            }
        }
        .padding(24)
        .frame(width: 400)
        .background(TogglTheme.backgroundTertiary)
        .alert("Time overlap detected", isPresented: $showOverlapWarning) {
            Button("Cancel", role: .cancel) {
                pendingSave = false
            }
            Button("Save anyway", role: .destructive) {
                commitSave()
            }
        } message: {
            Text("There's already an entry in this time range. Save anyway?")
        }
    }

    private func attemptSave() {
        guard validationError == nil else { return }
        let overlaps = onDetectOverlaps(startTime, endTime)
        if overlaps.isEmpty {
            commitSave()
        } else {
            pendingSave = true
            showOverlapWarning = true
        }
    }

    private func commitSave() {
        onSave(startTime, endTime, taskDescription, selectedProject)
    }
}
