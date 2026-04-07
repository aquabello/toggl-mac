import SwiftUI

struct ProjectEditView: View {
    let project: Project?
    let onSave: (String, String) -> Void
    let onCancel: () -> Void

    @State private var name: String = ""
    @State private var selectedColor: String = "E57CD8"

    private let colorPalette = TogglTheme.projectColors

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(project == nil ? "New project" : "Edit project")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(TogglTheme.textPrimary)

            // Name input
            VStack(alignment: .leading, spacing: 6) {
                Text("NAME")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(TogglTheme.textTertiary)
                    .tracking(0.8)
                TextField("Project name", text: $name)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                    .foregroundStyle(TogglTheme.textPrimary)
                    .togglInput()
            }

            // Color palette
            VStack(alignment: .leading, spacing: 8) {
                Text("COLOR")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(TogglTheme.textTertiary)
                    .tracking(0.8)

                LazyVGrid(columns: Array(repeating: GridItem(.fixed(30)), count: 6), spacing: 8) {
                    ForEach(colorPalette, id: \.self) { color in
                        Circle()
                            .fill(Color(hex: color))
                            .frame(width: 26, height: 26)
                            .overlay(
                                Circle()
                                    .stroke(.white, lineWidth: selectedColor == color ? 2.5 : 0)
                            )
                            .shadow(color: selectedColor == color ? Color(hex: color).opacity(0.5) : .clear, radius: 4)
                            .onTapGesture {
                                selectedColor = color
                            }
                    }
                }
            }

            Rectangle()
                .fill(TogglTheme.divider)
                .frame(height: 1)

            // Actions
            HStack {
                Button("Cancel") {
                    onCancel()
                }
                .foregroundStyle(TogglTheme.textSecondary)

                Spacer()

                Button(action: {
                    guard !name.isEmpty else { return }
                    onSave(name, selectedColor)
                }) {
                    Text("Save")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(name.isEmpty ? TogglTheme.textTertiary : TogglTheme.accentPink)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .disabled(name.isEmpty)
            }
        }
        .padding(18)
        .frame(width: 260)
        .background(TogglTheme.backgroundTertiary)
        .onAppear {
            if let project {
                name = project.name
                selectedColor = project.colorHex
            }
        }
    }
}
