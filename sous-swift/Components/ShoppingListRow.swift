import SwiftUI

struct ShoppingListRow: View {
    let pantryItem: PantryItem
    let isShowingAllItems: Bool
    let onPurchase: () async -> Void
    let onAddToList: () async -> Void
    let onDelete: (_ id: Int) async -> Void
    let onEdit: () async -> Void

    init(
        pantryItem: PantryItem,
        isShowingAllItems: Bool = false,
        onPurchase: @escaping () async -> Void,
        onAddToList: @escaping () async -> Void,
        onDelete: @escaping (_: Int) async -> Void,
        onEdit: @escaping () async -> Void
    ) {
        self.pantryItem = pantryItem
        self.isShowingAllItems = isShowingAllItems
        self.onPurchase = onPurchase
        self.onAddToList = onAddToList
        self.onDelete = onDelete
        self.onEdit = onEdit
    }

    var body: some View {
        let canBeAdded = isShowingAllItems && !pantryItem.isInShoppingList
        ListItem(
            text: pantryItem.name,
            dimText: canBeAdded,
            leftAdornment: {},
            rightAdornment: {
                ZStack {
                    Circle()
                        .fill(.clear)
                        .frame(width: 24, height: 24)
                    if !isShowingAllItems {
                        Image(systemName: "repeat")
                            .foregroundColor(
                                pantryItem.isFavorite
                                    ? Color.pPrimary : Color.pIndeterminate
                            )
                    } else if (isShowingAllItems && canBeAdded) {
                        Image(systemName: "plus")
                            .foregroundColor(Color.pPrimary)
                    } else if (isShowingAllItems && !canBeAdded) {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color.pIndeterminate)
                    }
                }
            }
        )
        .onTapGesture {
            Task {
                if isShowingAllItems && canBeAdded {
                    await onAddToList()
                } else {
                    await onPurchase()
                }
            }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                Task { await onDelete(pantryItem.id) }
            } label: {
                Label("delete", systemImage: "trash")
            }
            Button {
                Task { await onEdit() }
            } label: {
                Label("edit", systemImage: "pencil")
            }
        }
    }
}
