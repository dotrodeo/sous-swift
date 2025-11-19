import Clerk
import SwiftData
import SwiftUI

@main
struct sous_swiftApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var sessionManagerHolder = SessionManagerHolder()

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = UIBlurEffect(
            style: .systemUltraThinMaterial
        )
        appearance.backgroundColor = UIColor.clear

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if let manager = sessionManagerHolder.manager {
                    ContentView()
                        .environmentObject(manager)
                        .environment(\.clerk, Clerk.shared)
                } else {
                    ProgressView()
                }
            }
            .environmentObject(appState)
            .task {
                // Configure Clerk
                Clerk.shared.configure(
                    publishableKey:
                        "pk_test_cHVtcGVkLXdyZW4tNDEuY2xlcmsuYWNjb3VudHMuZGV2JA"
                )
                try? await Clerk.shared.load()
                print("Loaded Clerk")

                if sessionManagerHolder.manager == nil {
                    let manager = SessionManager(
                        clerk: Clerk.shared,
                        appState: appState
                    )
                    sessionManagerHolder.manager = manager
                    await manager.handleAuthEvent()
                }
            }
        }
    }
}
