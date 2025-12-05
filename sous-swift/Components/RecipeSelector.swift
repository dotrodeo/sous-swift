import SwiftUI

struct RecipeSelector: View {
    @Binding var isSaving: Bool
    @State private var selectedItems = Set<Int>()
    @State private var isEditing = true
    var recipes: [Recipe]
    var onSave: (Set<Int>) async -> Void

    @Environment(\.editMode) private var editMode

    var body: some View {
        VStack {
            HStack {
                Poppins("select recipes")
                    .size(24)
                    .weight(.medium)
                Spacer()
                SaveButton(isSaving: $isSaving) {
                    await onSave(selectedItems)
                }
            }
            .padding(.top, 32)
            .padding(.horizontal, 16)
            .zIndex(100)
            List(selection: $selectedItems) {
                ForEach(recipes) { recipe in
                    Poppins(recipe.name)
                        .textCase(.lowercase)
                }
            }
            .environment(
                \.editMode,
                .constant(isEditing ? EditMode.active : EditMode.inactive)
            )
        }
    }
}
