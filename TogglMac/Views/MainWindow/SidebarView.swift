import SwiftUI

struct SidebarView: View {
    let projectViewModel: ProjectViewModel
    let onSelectProject: (Project?) -> Void
    @State private var isAddingProject = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("프로젝트")
                    .font(.headline)
                Spacer()
                Button(action: { isAddingProject = true }) {
                    Image(systemName: "plus")
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider()

            ScrollView {
                ProjectListView(
                    projects: projectViewModel.projects,
                    selectedProject: projectViewModel.selectedProject,
                    onSelect: onSelectProject
                )
                .padding(.horizontal, 4)
            }
        }
        .frame(minWidth: AppConstants.UI.sidebarWidth)
        .popover(isPresented: $isAddingProject) {
            ProjectEditView(
                project: nil,
                onSave: { name, color in
                    projectViewModel.createProject(name: name, colorHex: color)
                    isAddingProject = false
                },
                onCancel: { isAddingProject = false }
            )
        }
    }
}
