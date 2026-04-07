import SwiftUI

struct SidebarView: View {
    let projectViewModel: ProjectViewModel
    let timerViewModel: TimerViewModel
    let onSelectProject: (Project?) -> Void
    @State private var isAddingProject = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // App title area
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundStyle(TogglTheme.accentPink)
                    .font(.system(size: 14))
                Text("TogglMac")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(TogglTheme.textPrimary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            // Active timer indicator
            if timerViewModel.isRunning {
                HStack(spacing: 8) {
                    Circle()
                        .fill(TogglTheme.accentGreen)
                        .frame(width: 8, height: 8)
                        .shadow(color: TogglTheme.accentGreen.opacity(0.6), radius: 4)
                    Text(timerViewModel.formattedElapsedTime)
                        .font(.system(size: 13, weight: .medium).monospacedDigit())
                        .foregroundStyle(TogglTheme.accentGreen)
                    Image(systemName: "pencil")
                        .font(.system(size: 10))
                        .foregroundStyle(TogglTheme.textTertiary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(TogglTheme.accentGreen.opacity(0.08))
            }

            sidebarDivider

            // TRACK section
            sectionHeader("TRACK")
            sidebarItem(icon: "chart.bar.fill", label: "Overview")
            sidebarDivider

            // ANALYZE section
            sectionHeader("ANALYZE")
            sidebarItem(icon: "chart.pie.fill", label: "Reports")
            sidebarDivider

            // MANAGE section
            sectionHeader("MANAGE")

            HStack {
                Image(systemName: "folder.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(TogglTheme.textSecondary)
                    .frame(width: 20)
                Text("Projects")
                    .font(.system(size: 13))
                    .foregroundStyle(TogglTheme.textPrimary)
                Spacer()
                Button(action: { isAddingProject = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 11))
                        .foregroundStyle(TogglTheme.textTertiary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)

            ScrollView {
                ProjectListView(
                    projects: projectViewModel.projects,
                    selectedProject: projectViewModel.selectedProject,
                    onSelect: onSelectProject
                )
                .padding(.horizontal, 8)
                .padding(.top, 4)
            }

            Spacer()

            // Bottom items
            sidebarDivider
            sidebarItem(icon: "tag.fill", label: "Tags")
            sidebarItem(icon: "target", label: "Goals")
            sidebarItem(icon: "puzzlepiece.fill", label: "Integrations", badge: "NEW")
        }
        .frame(minWidth: AppConstants.UI.sidebarWidth)
        .background(TogglTheme.backgroundSidebar)
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

    // MARK: - Components

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(TogglTheme.sectionLabel)
            .tracking(1.2)
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 4)
    }

    private func sidebarItem(icon: String, label: String, badge: String? = nil) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(TogglTheme.textSecondary)
                .frame(width: 20)
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(TogglTheme.textSecondary)
            Spacer()
            if let badge {
                Text(badge)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(TogglTheme.accentPink)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(TogglTheme.accentPink.opacity(0.15))
                    .cornerRadius(4)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }

    private var sidebarDivider: some View {
        Rectangle()
            .fill(TogglTheme.divider)
            .frame(height: 1)
            .padding(.horizontal, 12)
    }
}
