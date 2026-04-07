import SwiftUI
import AppKit

struct EntryEditPanel: View {
    let entry: TimeEntry
    let projects: [Project]
    let onUpdateDescription: (String) -> Void
    let onUpdateProject: (Project?) -> Void
    let onUpdateTime: ((Date, Date) -> Void)?
    let onDelete: () -> Void
    let onDismiss: () -> Void

    @State private var editingDescription: String = ""
    @State private var selectedProjectId: UUID?
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date()

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
            VStack(alignment: .leading, spacing: 6) {
                Text("DESCRIPTION")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(TogglTheme.textTertiary)
                    .tracking(0.8)
                TextField("Task name", text: $editingDescription)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                    .foregroundStyle(TogglTheme.textPrimary)
                    .togglInput()
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

            // Time pickers
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("START")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(TogglTheme.textTertiary)
                        .tracking(0.8)
                    DatePicker("", selection: $startTime, displayedComponents: [.hourAndMinute])
                        .labelsHidden()
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("END")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(TogglTheme.textTertiary)
                        .tracking(0.8)
                    DatePicker("", selection: $endTime, displayedComponents: [.hourAndMinute])
                        .labelsHidden()
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("DURATION")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(TogglTheme.textTertiary)
                        .tracking(0.8)
                    Text(DateHelpers.formattedElapsedTime(endTime.timeIntervalSince(startTime)))
                        .font(.system(size: 13, weight: .medium).monospacedDigit())
                        .foregroundStyle(TogglTheme.textPrimary)
                }
            }

            Rectangle()
                .fill(TogglTheme.divider)
                .frame(height: 1)

            // Action buttons
            HStack {
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

                Spacer()

                Button(action: saveChanges) {
                    Text("Save")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(TogglTheme.accentPink)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .frame(width: 320)
        .background(TogglTheme.backgroundTertiary)
        .cornerRadius(12)
        .onAppear {
            editingDescription = entry.taskDescription
            selectedProjectId = entry.project?.id
            startTime = entry.startTime
            endTime = entry.endTime
        }
    }

    private func saveChanges() {
        // 한글 조합 중인 입력을 강제 완성 (first responder 해제)
        NSApp.keyWindow?.makeFirstResponder(nil)

        // 약간의 딜레이 후 저장 (조합 완성이 editingDescription에 반영되도록)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            performSave()
        }
    }

    private func performSave() {
        onUpdateDescription(editingDescription)

        // Preserve original date, only update hours/minutes
        let calendar = Calendar.current
        let originalDate = entry.startTime
        var startComps = calendar.dateComponents([.hour, .minute], from: startTime)
        var endComps = calendar.dateComponents([.hour, .minute], from: endTime)

        let dayComps = calendar.dateComponents([.year, .month, .day], from: originalDate)
        startComps.year = dayComps.year
        startComps.month = dayComps.month
        startComps.day = dayComps.day
        endComps.year = dayComps.year
        endComps.month = dayComps.month
        endComps.day = dayComps.day

        if let newStart = calendar.date(from: startComps),
           let newEnd = calendar.date(from: endComps),
           newStart < newEnd,
           (newStart != entry.startTime || newEnd != entry.endTime) {
            onUpdateTime?(newStart, newEnd)
        }

        onDismiss()
    }
}
