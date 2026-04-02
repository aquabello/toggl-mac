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
            return "종료 시간은 시작 시간보다 나중이어야 합니다."
        }
        return nil
    }

    private var selectedProject: Project? {
        projects.first { $0.id == selectedProjectId }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("시간 항목 추가")
                .font(.headline)

            Divider()

            TextField("업무명", text: $taskDescription)
                .textFieldStyle(.roundedBorder)

            VStack(alignment: .leading, spacing: 8) {
                DatePicker("시작 시간", selection: $startTime, displayedComponents: [.date, .hourAndMinute])
                DatePicker("종료 시간", selection: $endTime, displayedComponents: [.date, .hourAndMinute])
            }

            if let error = validationError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Picker("프로젝트", selection: $selectedProjectId) {
                Text("프로젝트 없음").tag(nil as UUID?)
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

            Divider()

            HStack {
                Button("취소", action: onCancel)
                    .keyboardShortcut(.escape, modifiers: [])
                Spacer()
                Button("저장") {
                    attemptSave()
                }
                .keyboardShortcut(.return, modifiers: .command)
                .disabled(validationError != nil)
            }
        }
        .padding()
        .frame(width: 360)
        .alert("시간 겹침 감지", isPresented: $showOverlapWarning) {
            Button("취소", role: .cancel) {
                pendingSave = false
            }
            Button("계속 저장", role: .destructive) {
                commitSave()
            }
        } message: {
            Text("선택한 시간대에 이미 다른 항목이 있습니다. 계속 저장하시겠습니까?")
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
