import Combine
import SwiftUI

@MainActor
class RecipeViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    func loadRecipes() async {
        isLoading = true
        errorMessage = nil

        do {
            self.recipes = try await APIHelper.get(
                "http://localhost:8080/household/1/recipes",
                type: [Recipe].self
            )
        } catch {
            errorMessage =
                "Failed to load recipes: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
