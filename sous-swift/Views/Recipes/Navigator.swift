import SwiftData
import SwiftUI

enum RecipeRoute: Hashable {
    case recipeList
    case recipeDetail(Int)
    case editRecipe(Int?)  // nil = new recipe
}

struct RecipeNavigator: View {
    let startingRoute: RecipeRoute?

    @State private var path = NavigationPath()
    @State private var hasSetInitialRoute = false
    @EnvironmentObject private var sessionManager: SessionManager
    
    func checkSession() {
        print(sessionManager.isReady)
    }

    var body: some View {
        if !sessionManager.isReady {
            ProgressView()
        } else {
            NavigationStack(path: $path) {
                RecipesView(
                    path: $path,
                    recipeService: sessionManager.recipeService!,
                    pantryService: sessionManager.pantryService!
                )
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
                            recipeService: sessionManager.recipeService!
                        )
                    case .editRecipe(let id):
                        RecipeEditView(
                            path: $path,
                            recipeId: id,
                            recipeService: sessionManager.recipeService!
                        )
                    }
                }
            }
            .onAppear {
                guard !hasSetInitialRoute else { return }
                hasSetInitialRoute = true
                
                if let startingRoute {
                    path.append(startingRoute)
                }
            }
        }
    }
}

#Preview {
    RecipeNavigator(startingRoute: RecipeRoute.recipeDetail(13))
}
