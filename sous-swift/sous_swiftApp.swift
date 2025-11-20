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

    private func clerkPublishableKey() -> String {
        if let env = ProcessInfo.processInfo.environment["CLERK_PUBLISHABLE_KEY"],
           !env.isEmpty {
            return env
        }

        if let key = Bundle.main.object(forInfoDictionaryKey: "ClerkPublishableKey") as? String,
           !key.isEmpty {
            return key
        }
        
        fatalError("Missing Clerk publishable key. Provide CLERK_PUBLISHABLE_KEY via Secrets.xcconfig (ignored) or Scheme env var.")
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if let manager = sessionManagerHolder.manager {
                    ContentView()
                        .environmentObject(manager)
                        .environment(\.clerk, Clerk.shared)
                } else {
                    LoadingOverlay()
                }
            }
            .environmentObject(appState)
            .task {
                Clerk.shared.configure(
                    publishableKey: clerkPublishableKey()
                )
                try? await Clerk.shared.load()

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
