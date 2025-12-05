import Combine
import SwiftUI

struct CategoryWithItems {
    var name: String
    var category: ItemCategory?
    var pantryItems: [PantryItem]
}

@MainActor
class ListViewModel: ObservableObject {
    @Published var pantry: Pantry?
    @Published var categories: [ItemCategory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText: String? = ""

    private let pantryService: PantryServiceProtocol
    private let sseService: SSEServiceProtocol

    init(
        pantryService: PantryServiceProtocol,
        sseService: SSEServiceProtocol
    ) {
        self.pantryService = pantryService
        self.sseService = sseService
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil

        do {
            pantry = try await pantryService.fetchPantry()

            if let pantry {
                categories = try await pantryService.fetchCategories(
                    pantryId: pantry.id
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func listen() {
        Task {
            let stream = sseService.stream()
            for await event in stream {
                if event.type == SSEMessageType.pantryUpdate
                    || event.type == SSEMessageType.categoryUpdate
                {
                    // TODO: Implement sender and don't refresh on own updates
                    await refresh()
                }
            }
        }
    }

    func addItemToList(_ item: PantryItem) async {
        guard var pantry = pantry else { return }
        let oldPantry = pantry

        let patch = PantryItemPatch(
            id: item.id,
            isInShoppingList: true,
        )

        if let index = pantry.pantryItems.firstIndex(where: { $0.id == item.id }
        ) {
            let updated = pantry.pantryItems[index].copy(
                isInShoppingList: patch.isInShoppingList,
            )
            pantry.pantryItems[index] = updated
        }
        self.pantry = pantry

        await upsertItem(patch, fallback: oldPantry)
    }

    func purchaseItem(_ item: PantryItem) async {
        guard var pantry = pantry else { return }
        let oldPantry = pantry

        let patch = PantryItemPatch(
            id: item.id,
            isInStock: true,
            isInShoppingList: false,
            purchasedAt: DateHelper.toString(Date())
        )

        if let index = pantry.pantryItems.firstIndex(where: { $0.id == item.id }
        ) {
            let updated = pantry.pantryItems[index].copy(
                isInShoppingList: false,
                isInStock: true,
                purchasedAt: patch.purchasedAt
            )
            pantry.pantryItems[index] = updated
        }
        self.pantry = pantry

        await upsertItem(patch, fallback: oldPantry)
    }

    func saveItem(_ patch: PantryItemPatch) async {
        guard let pantry = pantry else { return }
        let oldPantry = pantry
        print("Saving item \(patch.name ?? "")")

        await upsertItem(patch, fallback: oldPantry)
    }

    func deleteItem(_ item: PantryItem) async {
        guard var pantry = pantry else { return }
        let oldPantry = pantry

        let patch = PantryItemPatch(
            id: item.id,
            isInShoppingList: false,
            deletedAt: DateHelper.toString(Date())
        )

        if let index = pantry.pantryItems.firstIndex(where: { $0.id == item.id }
        ) {
            let updated = pantry.pantryItems[index].copy(
                isInShoppingList: false,
                deletedAt: patch.deletedAt
            )
            pantry.pantryItems[index] = updated
        }
        self.pantry = pantry

        await upsertItem(patch, fallback: oldPantry)
    }

    func inShoppingList(showAll: Bool = false) -> [PantryItem] {
        (pantry?.pantryItems ?? [])
            .filter { item in
                guard let text = searchText, !text.isEmpty else { return true }
                return item.name.localizedCaseInsensitiveContains(text)
            }
            .filter { showAll || $0.isInShoppingList }
            .sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name)
                    == .orderedAscending
            }
    }

    func forListView(showAll: Bool = false) -> [CategoryWithItems] {
        let items = inShoppingList(showAll: showAll)

        let validItems = items.compactMap {
            item -> (category: ItemCategory, item: PantryItem)? in
            guard let category = item.category else { return nil }
            return (category, item)
        }

        let grouped = Dictionary(grouping: validItems, by: { $0.category.id })

        var result = grouped.values.map { group in
            let category = group.first!.category

            return CategoryWithItems(
                name: category.name,
                category: category,
                pantryItems: group.map { $0.item }
            )
        }

        let uncategorizedItems = items.filter { $0.category == nil }
        if !uncategorizedItems.isEmpty {
            let uncategorized = CategoryWithItems(
                name: "Uncategorized",
                category: nil,
                pantryItems: uncategorizedItems
            )
            result.append(uncategorized)
        }

        return result.sorted {
            $0.category?.sortOrder ?? .max < $1.category?.sortOrder ?? .max
        }
    }

    private func upsertItem(_ patch: PantryItemPatch, fallback: Pantry? = nil)
        async
    {
        guard let pantry = pantry else { return }

        isLoading = true
        do {
            _ = try await pantryService.upsertPantryItem(
                pantryId: pantry.id,
                patch: patch
            )

            await refresh()
        } catch {
            if let fallback {
                self.pantry = fallback
                self.errorMessage =
                    "Failed to update item: \(error.localizedDescription)"
            }
        }
        isLoading = false
    }
}
