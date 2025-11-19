import SwiftUI

struct PantryItemModal: View {
    @Binding var pantryItem: PantryItemPatch
    var categories: [ItemCategory]
    var onSave: () async -> Void

    enum Field { case name }
    @FocusState private var focusedField: Field?

    @State private var isSaving: Bool = false
    @State private var saveIcon: String = "circle.dotted"

    var canSave: Bool {
        pantryItem.name != "" && !isSaving
    }

    // Bridge optional name to non-optional binding for TextInput
    private var nameBinding: Binding<String> {
        Binding<String>(
            get: { pantryItem.name ?? "" },
            set: { newValue in
                pantryItem.name = newValue.isEmpty ? nil : newValue
            }
        )
    }

    // Bridge optional Bool? properties to non-optional Bool for UI
    private var isFavoriteBinding: Binding<Bool> {
        Binding<Bool>(
            get: { pantryItem.isFavorite ?? false },
            set: { newValue in
                pantryItem.isFavorite = newValue
            }
        )
    }

    private var isInStockBinding: Binding<Bool> {
        Binding<Bool>(
            get: { pantryItem.isInStock ?? false },
            set: { newValue in
                pantryItem.isInStock = newValue
            }
        )
    }

    private var isInShoppingListBinding: Binding<Bool> {
        Binding<Bool>(
            get: { pantryItem.isInShoppingList ?? false },
            set: { newValue in
                pantryItem.isInShoppingList = newValue
            }
        )
    }

    // Bridge optional categoryId to a Binding<Int?> for Picker
    private var categoryBinding: Binding<Int?> {
        Binding<Int?>(
            get: {
                // Show the current categoryId, or default to the first category's id for display
                pantryItem.categoryId ?? categories.first?.id
            },
            set: { newValue in
                pantryItem.categoryId = newValue
            }
        )
    }

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Poppins(pantryItem.id != nil ? "edit item" : "new item")
                    .size(24)
                    .weight(.medium)
                Spacer()
                Button {
                    Task {
                        isSaving = true
                        await onSave()
                        saveIcon = "checkmark"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            saveIcon = "circle.dotted"
                        }
                        isSaving = false
                    }
                } label: {
                    Poppins("save")
                        .size(16)
                        .weight(.medium)
                    Image(systemName: saveIcon)
                }
                .disabled(!canSave)
                .buttonStyle(.borderedProminent)
            }
            HStack(spacing: 8) {
                TextInput(
                    label: "name",
                    prompt: "all-purpose flour",
                    text: nameBinding,
                    focusedField: $focusedField,
                    equals: .name
                )
                ZStack {
                    Circle()
                        .frame(width: 40, height: 40)
                        .opacity(0.1)
                    Button {
                        // Toggle favorite by mutating the bound value, not the projected binding
                        pantryItem.isFavorite =
                            !(pantryItem.isFavorite ?? false)
                    } label: {
                        Image(systemName: "repeat")
                            .resizable()
                            .foregroundColor(
                                (pantryItem.isFavorite ?? false)
                                    ? Color.pPrimary
                                    : Color.pForeground.opacity(0.3)
                            )
                            .frame(width: 20, height: 20)
                            .padding(16)
                    }
                }
                .offset(x: 0, y: 12)
            }
            VStack(spacing: 4) {
                List {
                    Picker(selection: categoryBinding) {
                        ForEach(categories) { category in
                            Text(
                                "\(category.icon ?? "") \(category.name.lowercased())"
                            )
                            .tag(Optional(category.id))
                        }
                    } label: {
                        Poppins("category")
                            .size(14)
                            .weight(.medium)
                    }
                    Toggle(isOn: isInStockBinding) {
                        Text("in stock")
                    }
                    Toggle(isOn: isInShoppingListBinding) {
                        Text("in shopping list")
                    }
                }
                .listStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 32)
    }
}

//#Preview {
//    let emptyPantryItem = PantryItemPatch()
//    let sampleCategory = ItemCategory(
//        id: 1,
//        name: "produce",
//        sortOrder: 0,
//        icon: "🍎",
//        isNonFood: false,
//        createdAt: "",
//        updatedAt: "",
//        deletedAt: nil,
//        pantryItems: nil,
//        pantryId: 1,
//        pantry: nil
//    )
//    PantryItemModal(
//        pantryItem: emptyPantryItem,
//        categories: [sampleCategory],
//        onSave: { patch in }
//    )
//}
