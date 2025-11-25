import SwiftUI

struct PantryItemRow: View {
    let pantryItem: PantryItem
    let onTap: () -> Void
    let onToggleFavorite: (PantryItem) async -> Void
    let onMarkOutOfStock: (PantryItem) async -> Void
    let onDelete: (PantryItem) async -> Void

    var body: some View {
        let expiresAt =
            pantryItem.expiresAt != nil
            ? DateHelper.fromString(pantryItem.expiresAt!) : nil
        let isExpiring =
            expiresAt != nil && DateHelper.isWithinThreeDaysOrPast(expiresAt!)
        ListItem(
            text: pantryItem.name,
            leftAdornment: {
                statusDot(
                    pantryItem.isInStock,
                    isInShoppingList: pantryItem.isInShoppingList,
                    isFavorite: pantryItem.isFavorite
                )
            },
            rightAdornment: {
                HStack {
                    if pantryItem.isInStock && isExpiring {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .foregroundColor(Color.pPink)
                    }
                    ZStack {
                        Circle()
                            .fill(.clear)
                            .frame(width: 24, height: 24)
                        Image(systemName: "repeat")
                            .foregroundColor(
                                pantryItem.isFavorite
                                    ? Color.pPrimary : Color.pIndeterminate
                            )
                    }
                    .onTapGesture {
                        Task {
                            await onToggleFavorite(pantryItem)
                        }
                    }
                }
            }
        )
        .onTapGesture(perform: onTap)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                Task {
                    await onDelete(pantryItem)
                }
            } label: {
                Label("delete", systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading) {
            Button {
                Task {
                    await onMarkOutOfStock(pantryItem)
                }
            } label: {
                Label("out of stock", systemImage: "circle.slash")
            }
        }
    }
}

private func statusDot(
    _ isInStock: Bool,
    isInShoppingList: Bool = false,
    isFavorite: Bool = false
)
    -> some View
{
    if !isInStock && isInShoppingList {
        return AnyView(
            ZStack {
                Image(systemName: "cart")
                    .foregroundColor(Color.pForeground.opacity(0.5))
                    .frame(
                        width: 16,
                        height: 16
                    )
            }
        )
    }

    if isFavorite {
        return AnyView(
            ZStack {
                Image(systemName: "star.circle.fill")
                    .foregroundColor(
                        isInStock ? Color.pSuccess : Color.pIndeterminate
                    )
                    .frame(
                        width: 16,
                        height: 16
                    )
            }
        )
    }

    return AnyView(
        ZStack {
            Circle()
                .fill(
                    isInStock
                        ? Color.pSuccess
                        : Color.pIndeterminate
                )
                .frame(
                    width: 16,
                    height: 16
                )
        }
    )
}
