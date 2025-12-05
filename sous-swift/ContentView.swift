import Clerk
import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.clerk) private var clerk
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject private var appState: AppState
    @State private var authIsPresented = false
    @State private var authMode: AuthView.Mode = .signIn

    var body: some View {
        ZStack {
            if sessionManager.isLoggedIn {
                if sessionManager.isReady {
                    TabView(selection: $appState.currentTab) {
                        Tab("recipes", systemImage: "book", value: .recipes) {
                            RecipeNavigator()
                        }
                        Tab("plan", systemImage: "calendar", value: .plan) {
                            PlanNavigator()
                        }
                        Tab("pantry", systemImage: "refrigerator", value: .pantry) {
                            PantryNavigator()
                        }
                        Tab("list", systemImage: "cart", value: .list) {
                            ListNavigator()
                        }
                        Tab("settings", systemImage: "gear", value: .settings) {
                            ProfileNavigator()
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
