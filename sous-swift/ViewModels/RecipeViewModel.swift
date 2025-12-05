import Combine
import SwiftUI

@MainActor
class RecipeViewModel: ObservableObject {
    @Published var recipe: Recipe? = nil
    @Published var pantry: Pantry? = nil
    @Published var importedRecipe: RecipeImport? = nil
    @Published var tags: [RecipeTag] = []
//    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @State private var loadingCount: Int = 0
    
    var isLoading: Bool {
        loadingCount > 0
    }

    private let recipeId: Int?
    private let recipeService: RecipeServiceProtocol
    private let pantryService: PantryServiceProtocol

    init(
        recipeId: Int?,
        recipeService: RecipeServiceProtocol,
        pantryService: PantryServiceProtocol
    ) {
        self.recipeId = recipeId
        self.recipeService = recipeService
        self.pantryService = pantryService
    }

    func loadRecipe() async {
        guard let recipeId else { return }
        loadingCount += 1
        errorMessage = nil

        do {
            recipe = try await recipeService.fetchRecipe(id: recipeId)
            pantry = try await pantryService.fetchPantry()
        } catch {
            errorMessage = error.localizedDescription
        }

        loadingCount -= 1
    }
    
    func loadTags() async {
        loadingCount += 1
        do {
            tags = try await recipeService.getAllTags()
        } catch {
            errorMessage = error.localizedDescription
        }
        loadingCount -= 1
    }

    func importRecipe(from url: URL) async {
        loadingCount += 1
        errorMessage = nil

        do {
            importedRecipe = try await recipeService.importRecipe(url: url)
        } catch {
            errorMessage = error.localizedDescription
        }
        loadingCount -= 1
    }
    
    func saveRecipe(_ patch: RecipePatch) async {
        await upsertRecipe(patch, fallback: recipe)
    }
    
    func deleteRecipe(_ recipe: Recipe) async {
        loadingCount += 1
        do {
            _ = try await recipeService.deleteRecipe(id: recipe.id)
            await loadRecipe()
        } catch {
            print(error.localizedDescription)
        }
        loadingCount -= 1
    }

    func addToShoppingList(_ item: PantryItem) async {
        await addToShoppingList(PantryItemPatch(from: item))
    }
    
    func addToShoppingList(_ item: PantryItemPatch) async {
        guard var pantry = pantry else { return }
        let oldPantry = pantry

        let patch = PantryItemPatch(
            id: item.id,
            name: item.name,
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

    func matchToPantryItem(_ ingredient: String) -> PantryItem? {
        guard let pantry else { return nil }
        let search = FuzzySearch(items: pantry.pantryItems, keyPath: \.name)
        let results = search.search(ingredient)

        if results.count >= 1 && results[0].score <= Constants.FUZZY_SEARCH_THRESHOLD {
            return results[0].item
        }

        return nil
    }
    
    private func upsertRecipe(_ patch: RecipePatch, fallback: Recipe? = nil) async {
        do {
            _ = try await recipeService.upsertRecipe(patch: patch)

            await loadRecipe()
        } catch {
            if let fallback {
                self.recipe = fallback
                self.errorMessage =
                    "Failed to update recipe: \(error.localizedDescription)"
            }
        }
    }

    private func upsertItem(_ patch: PantryItemPatch, fallback: Pantry? = nil)
        async
    {
        guard let pantry = pantry else { return }

        do {
            _ = try await pantryService.upsertPantryItem(
                pantryId: pantry.id,
                patch: patch
            )

            await loadRecipe()
        } catch {
            if let fallback {
                self.pantry = fallback
                self.errorMessage =
                    "Failed to update item: \(error.localizedDescription)"
            }
        }
    }
}
