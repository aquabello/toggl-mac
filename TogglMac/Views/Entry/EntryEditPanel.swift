import SwiftUI

struct EntryEditPanel: View {
    let entry: TimeEntry
    let projects: [Project]
    let onUpdateDescription: (String) -> Void
    let onUpdateProject: (Project?) -> Void
    let onDelete: () -> Void
    let onDismiss: () -> Void

    @State private var editingDescription: String = ""
    @State private var selectedProjectId: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Edit time entry")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(TogglTheme.textPrimary)
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(TogglTheme.textTertiary)
                        .frame(width: 24, height: 24)
                        .background(TogglTheme.surfaceCard)
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }

            Rectangle()
                .fill(TogglTheme.divider)
                .frame(height: 1)

            // Task description
            TextField("Task name", text: $editingDescription)
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .foregroundStyle(TogglTheme.textPrimary)
                .togglInput()
                .onSubmit {
                    onUpdateDescription(editingDescription)
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
                .onChange(of: selectedProjectId) { _, newValue in
                    let project = projects.first { $0.id == newValue }
                    onUpdateProject(project)
                }
            }

            // Time info
            HStack(spacing: 16) {
                timeInfoBlock(label: "START", value: entry.startTime)
                timeInfoBlock(label: "END", value: entry.endTime)
                VStack(alignment: .leading, spacing: 4) {
                    Text("DURATION")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(TogglTheme.textTertiary)
                        .tracking(0.8)
                    Text(DateHelpers.formattedElapsedTime(entry.duration))
                        .font(.system(size: 13, weight: .medium).monospacedDigit())
                        .foregroundStyle(TogglTheme.textPrimary)
                }
            }

            Rectangle()
                .fill(TogglTheme.divider)
                .frame(height: 1)

            // Delete button
            Button(action: onDelete) {
                HStack(spacing: 6) {
                    Image(systemName: "trash")
                        .font(.system(size: 11))
                    Text("Delete")
                        .font(.system(size: 12))
                }
                .foregroundStyle(TogglTheme.accentRed)
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .frame(width: 320)
        .background(TogglTheme.backgroundTertiary)
        .cornerRadius(12)
        .onAppear {
            editingDescription = entry.taskDescription
            selectedProjectId = entry.project?.id
        }
    }

    private func timeInfoBlock(label: String, value: Date) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(TogglTheme.textTertiary)
                .tracking(0.8)
            Text(value, style: .time)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(TogglTheme.textPrimary)
        }
    }
}
