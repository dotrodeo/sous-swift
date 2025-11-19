import SwiftData
import SwiftUI

enum ListRoute: Hashable {
    case list
    case editListItem(Int?)
}

struct ListNavigator: View {
    let startingRoute: ListRoute?

    @State private var path = NavigationPath()
    @State private var hasSetInitialRoute = false
    @EnvironmentObject private var sessionManager: SessionManager

    var body: some View {
        if !sessionManager.isReady {
            ProgressView()
        } else {
            NavigationStack(path: $path) {
                ListView(
                    path: $path,
                    pantryService: sessionManager.pantryService!
                )
                .navigationDestination(for: ListRoute.self) { route in
                    switch route {
                    case .list:
                        ListView(
                            path: $path,
                            pantryService: sessionManager.pantryService!
                        )
                    case .editListItem(let id):
                        RecipeEditView(
                            path: $path,
                            recipeId: id,
                            recipeService: sessionManager.recipeService!
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    ListNavigator(startingRoute: .list)
}
