import SwiftUI

enum RecipeRoute: Hashable, Codable {
    case recipeList
    case recipeDetail(Int)
    case bigMode(Int)
    case editRecipe(Int?)
}

struct RecipeRouter: ViewModifier {
    @Binding var path: NavigationPath
    @EnvironmentObject private var sessionManager: SessionManager

    func body(content: Content) -> some View {
        NavigationStack(path: $path) {
            content
                .navigationDestination(for: RecipeRoute.self) { route in
                    switch route {
                    case .recipeList:
                        RecipesView(
                            path: $path,
                            recipeService: sessionManager.recipeService!,
                            pantryService: sessionManager.pantryService!
                        )
                    case .recipeDetail(let id):
                        RecipeDetailView(
                            path: $path,
                            recipeId: id,
                            recipeService: sessionManager.recipeService!,
                            pantryService: sessionManager.pantryService!
                        )
                    case .bigMode(let id):
                        BigModeView(
                            path: $path,
                            recipeId: id,
                            recipeService: sessionManager.recipeService!,
                            pantryService: sessionManager.pantryService!
                        )
                    case .editRecipe(let id):
                        RecipeEditView(
                            path: $path,
                            recipeId: id,
                            recipeService: sessionManager.recipeService!,
                            pantryService: sessionManager.pantryService!
                        )
                    }
                }
        }
    }
}
