import Combine
import SwiftUI

@MainActor
class RecipeViewModel: ObservableObject {
    @Published var recipe: Recipe? = nil
    @Published var importedRecipe: RecipeImport? = nil
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let recipeService: RecipeServiceProtocol

    init(
        recipeService: RecipeServiceProtocol
    ) {
        self.recipeService = recipeService
    }

    func loadRecipe(id: Int) async {
        isLoading = true
        errorMessage = nil

        do {
            recipe = try await recipeService.fetchRecipe(id: id)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
    
    func importRecipe(from url: URL) async {
        isLoading = true
        errorMessage = nil
        
        do {
            importedRecipe = try await recipeService.importRecipe(url: url)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
