import SwiftUI

struct SaveButton: View {
    @Binding var isSaving: Bool
    @State private var rotate = false
    @State private var icon = "circle.dotted"
    @State private var background = Color.pPrimary
    var onTap: () async -> Void = {}

    var body: some View {
        Button(action: {
            Task {
                isSaving = true
                background = Color.pForeground.opacity(0.5)
                await onTap()
                background = Color.pSuccess
                icon = "checkmark"
                isSaving = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    background = Color.pPrimary
                    icon = "circle.dotted"
                }
            }
        }) {
            HStack {
                Poppins("save")
                    .size(16)
                    .weight(.medium)
                Image(systemName: icon)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(background)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                .red, .orange, .yellow, .green,
                                .blue, .indigo, .purple, .red,
                            ]),
                            center: .center,
                            angle: .degrees(rotate ? 360 : 0)
                        ),
                        lineWidth: isSaving ? 4 : 0
                    )
            )
            .onAppear {
                if isSaving {
                    background = Color.pForeground.opacity(0.5)
                }
                withAnimation(
                    .linear(duration: 2).repeatForever(autoreverses: false)
                ) {
                    rotate = true
                }
            }
        }
        .disabled(isSaving)
    }
}

#Preview {
    struct PreviewHost: View {
        @State var isSaving: Bool = false
        
        private func save() async {
            do {
                try await Task.sleep(for: .seconds(3))
            } catch {
                print("Woops")
            }
        }

        var body: some View {
            VStack(spacing: 8) {
                SaveButton(isSaving: .constant(true), onTap: {})
                SaveButton(
                    isSaving: $isSaving,
                    onTap: save
                )
            }
        }
    }

    return PreviewHost()
}
