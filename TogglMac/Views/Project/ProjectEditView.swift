import SwiftUI

struct ProjectEditView: View {
    let project: Project?
    let onSave: (String, String) -> Void
    let onCancel: () -> Void

    @State private var name: String = ""
    @State private var selectedColor: String = "FF6B6B"

    private let colorPalette = [
        "FF6B6B", "4ECDC4", "45B7D1", "96CEB4",
        "FFEAA7", "DDA0DD", "98D8C8", "F7DC6F",
        "BB8FCE", "85C1E9", "F0B27A", "AED6F1"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(project == nil ? "새 프로젝트" : "프로젝트 편집")
                .font(.headline)

            TextField("프로젝트 이름", text: $name)
                .textFieldStyle(.roundedBorder)

            Text("색상")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: Array(repeating: GridItem(.fixed(28)), count: 6), spacing: 8) {
                ForEach(colorPalette, id: \.self) { color in
                    Circle()
                        .fill(Color(hex: color))
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .stroke(Color.primary, lineWidth: selectedColor == color ? 2 : 0)
                        )
                        .onTapGesture {
                            selectedColor = color
                        }
                }
            }

            HStack {
                Button("취소", action: onCancel)
                Spacer()
                Button("저장") {
                    guard !name.isEmpty else { return }
                    onSave(name, selectedColor)
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.isEmpty)
            }
        }
        .padding()
        .frame(width: 250)
        .onAppear {
            if let project {
                name = project.name
                selectedColor = project.colorHex
            }
        }
    }
}
