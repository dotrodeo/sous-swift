import SwiftUI

struct ActionSheet: View {
    @Binding var isPresented: Bool
    let onEdit: () -> Void
    let onShare: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                onEdit()
                isPresented = false
            }) {
                Text("View Recipe")
                    .frame(maxWidth: .infinity)
                    .padding()
            }

            Divider()

            Button(action: {
                onShare()
                isPresented = false
            }) {
                Text("Edit Recipe")
                    .frame(maxWidth: .infinity)
                    .padding()
            }

            Divider()

            Button(
                role: .destructive,
                action: {
                    onDelete()
                    isPresented = false
                }
            ) {
                Text("Delete Recipe")
                    .frame(maxWidth: .infinity)
                    .padding()
            }

            Divider()

            Button(action: {
                isPresented = false
            }) {
                Text("Cancel")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.primary)
            }
        }
        .background(
            Color.clear
                .ignoresSafeArea()
        )
    }
}
