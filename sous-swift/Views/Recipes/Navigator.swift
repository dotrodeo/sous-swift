import SwiftData
import SwiftUI

struct RecipeNavigator: View {
    @EnvironmentObject private var sessionManager: SessionManager
    @EnvironmentObject private var appState: AppState

    var body: some View {
        if !sessionManager.isReady {
            ProgressView()
        } else {
            RecipesView(
                path: $appState.recipePath,
                recipeService: sessionManager.recipeService!,
                pantryService: sessionManager.pantryService!
            )
            .modifier(RecipeRouter(path: $appState.recipePath))
        }
    }
}
