import Combine
import SwiftUI

@MainActor
class PantryViewModel: ObservableObject {
    @Published var pantry: Pantry? = nil
    @Published var categories: [ItemCategory] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
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

    func inPantry() -> [PantryItem] {
        func isFood(_ item: PantryItem) -> Bool {
            return !(item.category?.isNonFood ?? false)
        }
        
        return Array(pantry?.pantryItems ?? [])
            .filter {
                guard let text = searchText, !text.isEmpty else { return true }
                return $0.name.localizedCaseInsensitiveContains(text)
            }
            .filter { isFood($0) && ($0.isInStock || $0.isFavorite) }
            .sorted {
                if $0.isInStock != $1.isInStock {
                    return $0.isInStock && !$1.isInStock
                }

                return $0.name.localizedCaseInsensitiveCompare($1.name)
                    == .orderedAscending
            }
    }
    
    func saveItem(_ patch: PantryItemPatch) async {
        guard let pantry = pantry else { return }
        let oldPantry = pantry
        print("Saving item \(patch.name ?? "")")
        
        await upsertItem(patch, fallback: oldPantry)
    }

    func markOutOfStock(_ item: PantryItem) async {
        guard var pantry = pantry else { return }
        let oldPantry = pantry

        var patch = PantryItemPatch(
            id: item.id,
            isInStock: false
        )

        if item.isFavorite {
            patch.isInShoppingList = true
        }

        if let index = pantry.pantryItems.firstIndex(where: { $0.id == item.id }
        ) {
            let updated = pantry.pantryItems[index].copy(
                isInShoppingList: patch.isInShoppingList,
                isInStock: false
            )
            pantry.pantryItems[index] = updated
        }
        self.pantry = pantry

        await upsertItem(patch, fallback: oldPantry)
    }
    
    func toggleFavorite(_ item: PantryItem) async {
        guard var pantry = pantry else { return }
        let oldPantry = pantry

        var patch = PantryItemPatch(
            id: item.id,
            isFavorite: !item.isFavorite,
        )

        if item.isFavorite {
            patch.isInShoppingList = true
        }

        if let index = pantry.pantryItems.firstIndex(where: { $0.id == item.id }
        ) {
            let updated = pantry.pantryItems[index].copy(
                isFavorite: patch.isFavorite,
            )
            pantry.pantryItems[index] = updated
        }
        self.pantry = pantry

        await upsertItem(patch, fallback: oldPantry)
    }
    
    func deleteItem(_ item: PantryItem) async {
        guard var pantry = pantry else { return }
        let oldPantry = pantry

        let patch = PantryItemPatch(
            id: item.id,
            isInStock: false,
            deletedAt: DateHelper.toString(Date())
        )
        
        if let index = pantry.pantryItems.firstIndex(where: { $0.id == item.id }) {
            let updated = pantry.pantryItems[index].copy(
                isInStock: false,
                deletedAt: patch.deletedAt
            )
            pantry.pantryItems[index] = updated
        }
        self.pantry = pantry
        
        await upsertItem(patch, fallback: oldPantry)
    }
    
    private func upsertItem(_ patch: PantryItemPatch, fallback: Pantry? = nil) async {
        guard let pantry = pantry else { return }

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
    }
}
