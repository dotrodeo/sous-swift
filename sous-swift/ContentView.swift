import Clerk
import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.clerk) private var clerk
    @EnvironmentObject var sessionManager: SessionManager
    @State private var authIsPresented = false
    @State private var authMode: AuthView.Mode = .signIn

    var body: some View {
        ZStack {
            if sessionManager.isLoggedIn {
                if sessionManager.isReady {
                    TabView {
                        Tab("Recipes", systemImage: "book") {
                            RecipeNavigator(
                                startingRoute: RecipeRoute.recipeList
                            )
                        }
                        Tab("Pantry", systemImage: "refrigerator") {
                            PantryNavigator(startingRoute: PantryRoute.pantry)
                        }
                        Tab("List", systemImage: "cart") {
                            ListNavigator(startingRoute: ListRoute.list)
                        }
                        Tab("Profile", systemImage: "smiley") {
                            UserProfileView()
                        }
                    }
                    .tabViewStyle(.sidebarAdaptable)
                } else {
                    LoadingOverlay()
                }
            } else {
                WelcomeScreen(
                    onPressGetStarted: {
                        authMode = .signUp
                        authIsPresented = true
                    },
                    onPressSignIn: {
                        authMode = .signIn
                        authIsPresented = true
                    }
                )
            }
        }
        .sheet(isPresented: $authIsPresented) {
            AuthView(mode: authMode)
        }
    }
}
