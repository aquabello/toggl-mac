import SwiftUI

struct ProjectListView: View {
    let projects: [Project]
    let selectedProject: Project?
    let onSelect: (Project?) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button(action: { onSelect(nil) }) {
                HStack {
                    Circle()
                        .fill(.gray)
                        .frame(width: 8, height: 8)
                    Text("전체")
                        .font(.subheadline)
                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(selectedProject == nil ? Color.accentColor.opacity(0.1) : Color.clear)
                .cornerRadius(4)
            }
            .buttonStyle(.plain)

            ForEach(projects) { project in
                Button(action: { onSelect(project) }) {
                    HStack {
                        Circle()
                            .fill(Color(hex: project.colorHex))
                            .frame(width: 8, height: 8)
                        Text(project.name)
                            .font(.subheadline)
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(selectedProject?.id == project.id ? Color.accentColor.opacity(0.1) : Color.clear)
                    .cornerRadius(4)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
