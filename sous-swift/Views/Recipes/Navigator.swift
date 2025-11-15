import SwiftData
import SwiftUI

enum RecipeRoute: Hashable {
    case recipeList
    case recipeDetail(Int)  // recipe ID
    case editRecipe(Int?)  // optional recipe ID for editing existing vs new
}

struct RecipeNavigator: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            RecipesView(path: $path)
                .navigationDestination(for: RecipeRoute.self) { route in
                    switch route {
                    case .recipeList:
                        RecipesView(path: $path)
                    case .recipeDetail(let id):
                        RecipeDetailView(recipeId: id)
                    case .editRecipe(let id):
                        RecipeEditView(recipeId: id)
                    }
                }
        }
    }
}

#Preview {
    RecipeNavigator()
}
