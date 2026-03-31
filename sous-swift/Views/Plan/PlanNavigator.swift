import SwiftData
import SwiftUI

struct PlanNavigator: View {
    @EnvironmentObject private var sessionManager: SessionManager
    @EnvironmentObject private var appState: AppState

    var body: some View {
        if !sessionManager.isReady {
            ProgressView()
        } else {
            PlanView(
                planService: sessionManager.planService!,
                recipeService: sessionManager.recipeService!,
                pantryService: sessionManager.pantryService!,
                onTapRecipe: { recipe in
                    appState.planPath.append(RecipeRoute.recipeDetail(recipe.id))
                }
            )
            .modifier(RecipeRouter(path: $appState.planPath))
        }
    }
}
