import Combine
import SwiftUI

@MainActor
final class RecipesViewModel: ObservableObject {
    @Published private(set) var recipes: [Recipe] = []
    @Published private(set) var pantry: Pantry? = nil
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var searchText: String? = ""
    // Tags selected by the UI; moving this into the VM so filtered results can be published
    @Published var selectedTags: Set<String> = []

    // The computed/published filtered recipes for the current searchText and selectedTags
    @Published private(set) var filteredRecipesPublished: [Recipe] = []

    private var cancellables = Set<AnyCancellable>()

    private let recipeService: RecipeServiceProtocol
    private let pantryService: PantryServiceProtocol

    init(
        recipeService: RecipeServiceProtocol,
        pantryService: PantryServiceProtocol
    ) {
        self.recipeService = recipeService
        self.pantryService = pantryService

        // Combine inputs to compute filtered recipes reactively
        Publishers.CombineLatest4($recipes, $pantry, $searchText, $selectedTags)
            .receive(on: DispatchQueue.main)
            .map { recipes, pantry, searchText, selectedTags -> [Recipe] in
                let pantryItems = pantry?.pantryItems ?? []

                let filtered = recipes
                    .filter { recipe in
                        guard let text = searchText, !text.isEmpty else { return true }
                        return recipe.name.localizedCaseInsensitiveContains(text)
                    }
                    .filter { recipe in
                        selectedTags.isEmpty ? true : {
                            guard let recipeTags = recipe.tags else { return false }
                            let recipeTagNames = recipeTags.map { $0.name }
                            return !selectedTags.isDisjoint(with: recipeTagNames)
                        }()
                    }

                return filtered.sorted { a, b in
                    let ra = RecipeHelper.ratio(for: a, pantryItems: pantryItems)
                    let rb = RecipeHelper.ratio(for: b, pantryItems: pantryItems)
                    return ra == rb ? a.name < b.name : ra > rb
                }
            }
            .assign(to: \.filteredRecipesPublished, on: self)
            .store(in: &cancellables)
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil
        RecipeHelper.clearRatioCache()

        async let recipesTask = recipeService.fetchRecipes()
        async let pantryTask = pantryService.fetchPantry()

        do {
            self.recipes = try await recipesTask
            self.pantry = try await pantryTask
        } catch {
            self.errorMessage = error.localizedDescription
            print(error.localizedDescription)
        }

        isLoading = false
    }
    
    func deleteRecipe(_ recipe: Recipe) async {
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await recipeService.deleteRecipe(id: recipe.id)
            await refresh()
        } catch {
            self.errorMessage = error.localizedDescription
            print(error.localizedDescription)
        }
    }

    var recipeTags: [String] {
        Array(
            Set(recipes.flatMap { $0.tags ?? [] }.map { $0.name })
        ).sorted()
    }

    func filteredRecipes(selectedTags: Set<String>) -> [Recipe] {
        // Backwards-compatible function in case direct call is needed
        let pantryItems = pantry?.pantryItems ?? []

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
