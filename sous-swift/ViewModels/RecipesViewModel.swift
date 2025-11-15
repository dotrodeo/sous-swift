import Combine
import SwiftUI

@MainActor
final class RecipesViewModel: ObservableObject {
    @Published private(set) var recipes: [Recipe] = []
    @Published private(set) var pantry: Pantry? = nil
    @Published private(set) var isLoading = false
    @Published var searchText: String = ""

    private let recipeApi: RecipeServiceProtocol
    private let pantryApi: PantryServiceProtocol

    // Cache per refresh
    private var ratioCache: [Int: Double] = [:]

    init(
        recipeApi: RecipeServiceProtocol,
        pantryApi: PantryServiceProtocol
    ) {
        self.recipeApi = recipeApi
        self.pantryApi = pantryApi
    }

    func refresh() async {
        isLoading = true
        ratioCache.removeAll()

        async let recipesTask = recipeApi.fetchRecipes()
        async let pantryTask = pantryApi.fetchPantry()

        do {
            self.recipes = try await recipesTask
            self.pantry = try await pantryTask
        } catch {
            // handle error if you want
        }

        isLoading = false
    }

    var recipeTags: [String] {
        Array(
            Set(recipes.flatMap { $0.tags ?? [] }.map { $0.name })
        )
    }

    func filteredRecipes(selectedTags: Set<String>) -> [Recipe] {
        guard let pantryItems = pantry?.pantryItems else { return [] }

        let filtered =
            recipes
            .filter {
                searchText.isEmpty
                    ? true
                    : $0.name.localizedCaseInsensitiveContains(searchText)
            }
            .filter {
                selectedTags.isEmpty
                    ? true : recipeMatchesTags($0, selectedTags)
            }

        return filtered.sorted { a, b in
            let ra = ratio(for: a, pantryItems: pantryItems)
            let rb = ratio(for: b, pantryItems: pantryItems)
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

    func ratio(for recipe: Recipe, pantryItems: [PantryItem]) -> Double
    {
        if let cached = ratioCache[recipe.id] {
            return cached
        }

        guard let ingredients = recipe.ingredients else {
            ratioCache[recipe.id] = 0
            return 0
        }

        let available = RecipeHelper.getAvailableIngredients(
            recipe: recipe,
            pantryItems: pantryItems
        )

        let val = Double(available.count) / Double(ingredients.count)
        ratioCache[recipe.id] = val
        return val
    }
}
