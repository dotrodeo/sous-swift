import MCEmojiPicker
import SwiftUI

struct ItemCategoryModal: View {
    @Binding var itemCategory: ItemCategoryPatch
    var onSave: () async -> Void

    enum Field { case name }
    @FocusState private var focusedField: Field?

    @State private var isSaving: Bool = false
    @State private var isPresented: Bool = false

    var canSave: Bool {
        itemCategory.name != "" && !isSaving
    }

    private var nameBinding: Binding<String> {
        Binding<String>(
            get: { itemCategory.name ?? "" },
            set: { newValue in
                itemCategory.name = newValue.isEmpty ? nil : newValue
            }
        )
    }

    private var iconBinding: Binding<String> {
        Binding<String>(
            get: { itemCategory.icon ?? "❓" },
            set: { newValue in
                itemCategory.icon = newValue.isEmpty ? nil : newValue
            }
        )
    }

    private var isNonFoodBinding: Binding<Bool> {
        Binding<Bool>(
            get: { itemCategory.isNonFood ?? false },
            set: { newValue in
                itemCategory.isNonFood = newValue
            }
        )
    }

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Poppins(
                    itemCategory.id != nil ? "edit category" : "new category"
                )
                .size(24)
                .weight(.medium)
                Spacer()
                SaveButton(isSaving: $isSaving) {
                    await onSave()
                }
            }
            HStack(spacing: 8) {
                TextInput(
                    label: "name",
                    prompt: "canned goods",
                    text: nameBinding,
                    focusedField: $focusedField,
                    equals: .name
                )
                Button {
                    isPresented.toggle()
                } label: {
                    Text(iconBinding.wrappedValue)
                        .padding(12)
                        .background(
                            Color.pForeground.opacity(0.2),
                            in: Circle()
                        )
                }
                .emojiPicker(
                    isPresented: $isPresented,
                    selectedEmoji: iconBinding
                )
                .offset(x: 0, y: 12)
            }
            List {
                Toggle(isOn: isNonFoodBinding) {
                    Text("non-food category")
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 32)
    }
}
