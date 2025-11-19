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
                statusDot(pantryItem.isInStock)
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

private func statusDot(_ isInStock: Bool) -> some View {
    return Circle()
        .fill(
            isInStock
                ? .green
                : Color.pIndeterminate
        )
        .frame(
            width: 12,
            height: 12
        )
}
