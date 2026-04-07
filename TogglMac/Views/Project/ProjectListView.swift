import SwiftUI

struct ProjectListView: View {
    let projects: [Project]
    let selectedProject: Project?
    let onSelect: (Project?) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            projectRow(
                color: TogglTheme.textTertiary,
                name: "All projects",
                isSelected: selectedProject == nil,
                action: { onSelect(nil) }
            )

            ForEach(projects) { project in
                projectRow(
                    color: Color(hex: project.colorHex),
                    name: project.name,
                    isSelected: selectedProject?.id == project.id,
                    action: { onSelect(project) }
                )
            }
        }
    }

    private func projectRow(color: Color, name: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                Text(name)
                    .font(.system(size: 12))
                    .foregroundStyle(isSelected ? TogglTheme.textPrimary : TogglTheme.textSecondary)
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                isSelected
                    ? TogglTheme.surfaceSelected.opacity(0.5)
                    : Color.clear
            )
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}
