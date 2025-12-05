import Combine
import SwiftUI

@MainActor
final class RecipesViewModel: ObservableObject {
    @Published private(set) var recipes: [Recipe] = []
    @Published private(set) var pantry: Pantry? = nil
    @Published private(set) var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var searchText: String? = ""

    private let recipeService: RecipeServiceProtocol
    private let pantryService: PantryServiceProtocol

    init(
        recipeService: RecipeServiceProtocol,
        pantryService: PantryServiceProtocol
    ) {
        self.recipeService = recipeService
        self.pantryService = pantryService
    }

    func refresh() async {
        isLoading = true
        RecipeHelper.clearRatioCache()

        async let recipesTask = recipeService.fetchRecipes()
        async let pantryTask = pantryService.fetchPantry()

        do {
            self.recipes = try await recipesTask
            self.pantry = try await pantryTask
        } catch {
            print(error.localizedDescription)
        }

        isLoading = false
    }
    
    func deleteRecipe(_ recipe: Recipe) async {
        isLoading = true
        
        do {
            _ = try await recipeService.deleteRecipe(id: recipe.id)
            await refresh()
        } catch {
            print(error.localizedDescription)
        }
    }

    var recipeTags: [String] {
        Array(
            Set(recipes.flatMap { $0.tags ?? [] }.map { $0.name })
        ).sorted()
    }

    func filteredRecipes(selectedTags: Set<String>) -> [Recipe] {
        guard let pantryItems = pantry?.pantryItems else { return [] }

        let filtered =
            recipes
            .filter {
                guard let text = searchText, !text.isEmpty else { return true }
                return $0.name.localizedCaseInsensitiveContains(text)
            }
            .filter {
                selectedTags.isEmpty
                    ? true : recipeMatchesTags($0, selectedTags)
            }

        return filtered.sorted { a, b in
            let ra = RecipeHelper.ratio(for: a, pantryItems: pantryItems)
            let rb = RecipeHelper.ratio(for: b, pantryItems: pantryItems)
            return ra == rb ? a.name < b.name : ra > rb
        }
    }

    private func recipeMatchesTags(_ recipe: Recipe, _ tags: Set<String>)
        -> Bool
    {
        guard let recipeTags = recipe.tags else { return false }
        // Compare the selected tag names with the recipe's tag names
        let recipeTagNames = recipeTags.map { $0.name }
        return !tags.isDisjoint(with: recipeTagNames)
    }
    
    private func upsertRecipe(_ patch: RecipePatch, fallback: [Recipe]? = nil) async {
        do {
            _ = try await recipeService.upsertRecipe(patch: patch)

            await refresh()
        } catch {
            print(error.localizedDescription)
            if let fallback {
                self.recipes = fallback
            }
            self.errorMessage =
                "Failed to update recipe: \(error.localizedDescription)"
        }
    }
}
