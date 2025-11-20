import Combine
import SwiftUI

@MainActor
class ListViewModel: ObservableObject {
    @Published var pantry: Pantry?
    @Published var categories: [ItemCategory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText: String? = ""

    private let pantryService: PantryServiceProtocol

    init(
        pantryService: PantryServiceProtocol
    ) {
        self.pantryService = pantryService
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil

        do {
            pantry = try await pantryService.fetchPantry()
            
            if let pantry {
                categories = try await pantryService.fetchCategories(pantryId: pantry.id)
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
    
    func addItemToList(_ item: PantryItem) async {
        guard var pantry = pantry else { return }
        let oldPantry = pantry

        let patch = PantryItemPatch(
            id: item.id,
            isInShoppingList: true,
        )

        if let index = pantry.pantryItems.firstIndex(where: { $0.id == item.id }) {
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
            isInShoppingList: false,
            purchasedAt: DateHelper.toString(Date())
        )

        if let index = pantry.pantryItems.firstIndex(where: { $0.id == item.id }) {
            let updated = pantry.pantryItems[index].copy(
                isInShoppingList: false,
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
        
        if let index = pantry.pantryItems.firstIndex(where: { $0.id == item.id }) {
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
    }

    func forListView(showAll: Bool = false) -> [(category: String, items: [PantryItem])] {
        let items = inShoppingList(showAll: showAll)

        return Dictionary(grouping: items) { item in
            "\(item.category?.icon ?? "") \(item.category?.name ?? "❓ uncategorized")"
        }
        .map { (category: $0.key, items: $0.value) }
        .sorted { $0.category < $1.category }
    }
    
    private func upsertItem(_ patch: PantryItemPatch, fallback: Pantry? = nil) async {
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
                self.errorMessage = "Failed to update item: \(error.localizedDescription)"
            }
        }
        isLoading = false
    }
}

