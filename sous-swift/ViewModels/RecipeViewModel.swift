import Combine
import SwiftUI

@MainActor
class RecipeViewModel: ObservableObject {
    @Published var recipe: Recipe? = nil
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let recipeApi: RecipeServiceProtocol

    init(recipeApi: RecipeServiceProtocol) {
        self.recipeApi = recipeApi
    }

    func loadRecipe(id: Int) async {
        isLoading = true
        errorMessage = nil

        do {
            recipe = try await recipeApi.fetchRecipe(id: id)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
