import SwiftData
import SwiftUI

enum PlanRoute: Hashable {
    case plan
}

struct PlanNavigator: View {
    let startingRoute: PlanRoute?

    @State private var path = NavigationPath()
    @State private var hasSetInitialRoute = false
    @EnvironmentObject private var sessionManager: SessionManager

    var body: some View {
        if !sessionManager.isReady {
            ProgressView()
        } else {
            NavigationStack(path: $path) {
                PlanView(
                    path: $path
                )
                .navigationDestination(for: PlanRoute.self) { route in
                    switch route {
                    case .plan:
                        PlanView(
                            path: $path
                        )
                    }
                }
            }
        }
    }
}
