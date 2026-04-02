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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("시간 항목 편집")
                    .font(.headline)
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            Divider()

            TextField("업무명", text: $editingDescription)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    onUpdateDescription(editingDescription)
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
            .onChange(of: selectedProjectId) { _, newValue in
                let project = projects.first { $0.id == newValue }
                onUpdateProject(project)
            }

            HStack {
                VStack(alignment: .leading) {
                    Text("시작")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(entry.startTime, style: .time)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("종료")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(entry.endTime, style: .time)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("소요 시간")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(DateHelpers.formattedElapsedTime(entry.duration))
                }
            }

            Divider()

            Button(role: .destructive, action: onDelete) {
                Label("삭제", systemImage: "trash")
            }
        }
        .padding()
        .frame(width: 300)
        .onAppear {
            editingDescription = entry.taskDescription
            selectedProjectId = entry.project?.id
        }
    }
}
