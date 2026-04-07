import SwiftUI
import AppKit

struct EntryEditPopover: View {
    let entry: TimeEntry
    let isActiveTimer: Bool
    let onUpdateDescription: (String) -> Void
    let onUpdateTime: ((Date, Date) -> Void)?
    let onStop: (() -> Void)?
    let onDelete: (() -> Void)?
    let onDismiss: () -> Void

    @State private var editingDescription: String = ""
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Top bar: stop button + more + close
            HStack(spacing: 8) {
                if isActiveTimer {
                    Button(action: { onStop?() }) {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(TogglTheme.accentRed)
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    .help("Stop timer")
                }

                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(TogglTheme.textTertiary)
                }
                .buttonStyle(.plain)

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(TogglTheme.textTertiary)
                        .frame(width: 22, height: 22)
                        .background(TogglTheme.surfaceCard)
                        .cornerRadius(11)
                }
                .buttonStyle(.plain)
            }

            // Description
            TextField("What are you working on?", text: $editingDescription)
                .textFieldStyle(.plain)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(TogglTheme.textPrimary)

            // Icon row (project, tag, billable)
            HStack(spacing: 12) {
                iconButton("folder", tooltip: "Project")
                iconButton("tag", tooltip: "Tags")
                iconButton("doc.text", tooltip: "Description")
                iconButton("dollarsign.circle", tooltip: "Billable")
            }

            // Time row
            HStack(spacing: 8) {
                DatePicker("", selection: $startTime, displayedComponents: [.hourAndMinute])
                    .labelsHidden()
                    .frame(width: 90)

                Image(systemName: "arrow.right")
                    .font(.system(size: 11))
                    .foregroundStyle(TogglTheme.textTertiary)

                if isActiveTimer {
                    Text(endTime, style: .time)
                        .font(.system(size: 13))
                        .foregroundStyle(TogglTheme.textSecondary)
                } else {
                    DatePicker("", selection: $endTime, displayedComponents: [.hourAndMinute])
                        .labelsHidden()
                        .frame(width: 90)
                }

                Spacer()

                Button(action: saveChanges) {
                    Text("Save")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(TogglTheme.accentPink)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .frame(width: 360)
        .background(TogglTheme.backgroundTertiary)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.5), radius: 16, y: 4)
        .onAppear {
            editingDescription = entry.taskDescription
            startTime = entry.startTime
            endTime = entry.endTime
        }
    }

    private func iconButton(_ systemName: String, tooltip: String) -> some View {
        Button(action: {}) {
            Image(systemName: systemName)
                .font(.system(size: 13))
                .foregroundStyle(TogglTheme.textTertiary)
        }
        .buttonStyle(.plain)
        .help(tooltip)
    }

    private func saveChanges() {
        // 한글 조합 강제 완성
        NSApp.keyWindow?.makeFirstResponder(nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            onUpdateDescription(editingDescription)

            // 시간 변경 처리 - 원래 날짜 보존
            let calendar = Calendar.current
            let dayComps = calendar.dateComponents([.year, .month, .day], from: entry.startTime)
            var startComps = calendar.dateComponents([.hour, .minute], from: startTime)
            startComps.year = dayComps.year
            startComps.month = dayComps.month
            startComps.day = dayComps.day

            if isActiveTimer {
                // 진행 중: 시작 시간만 변경
                if let newStart = calendar.date(from: startComps),
                   newStart != entry.startTime {
                    onUpdateTime?(newStart, entry.endTime)
                }
            } else {
                // 완료된 엔트리: 시작/종료 모두 변경
                var endComps = calendar.dateComponents([.hour, .minute], from: endTime)
                endComps.year = dayComps.year
                endComps.month = dayComps.month
                endComps.day = dayComps.day

                if let newStart = calendar.date(from: startComps),
                   let newEnd = calendar.date(from: endComps),
                   newStart < newEnd {
                    onUpdateTime?(newStart, newEnd)
                }
            }

            onDismiss()
        }
    }
}
