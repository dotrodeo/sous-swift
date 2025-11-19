import SwiftData
import SwiftUI

enum PantryRoute: Hashable {
    case pantry
    case editPantryItem(Int?)
}

struct PantryNavigator: View {
    let startingRoute: PantryRoute?

    @State private var path = NavigationPath()
    @State private var hasSetInitialRoute = false
    @EnvironmentObject private var sessionManager: SessionManager

    var body: some View {
        if !sessionManager.isReady {
            ProgressView()
        } else {
            NavigationStack(path: $path) {
                PantryView(
                    path: $path,
                    pantryService: sessionManager.pantryService!
                )
                .navigationDestination(for: PantryRoute.self) { route in
                    switch route {
                    case .pantry:
                        PantryView(
                            path: $path,
                            pantryService: sessionManager.pantryService!
                        )
                    case .editPantryItem(let id):
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
    PantryNavigator(startingRoute: .pantry)
}
