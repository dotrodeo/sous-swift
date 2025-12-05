import SwiftData
import SwiftUI

enum PantryRoute: Hashable {
    case pantry
}

struct PantryNavigator: View {

    @State private var path = NavigationPath()
    @EnvironmentObject private var sessionManager: SessionManager

    var body: some View {
        if !sessionManager.isReady {
            ProgressView()
        } else {
            NavigationStack(path: $path) {
                PantryView(
                    path: $path,
                    pantryService: sessionManager.pantryService!,
                    sseService: sessionManager.sseService!
                )
                .navigationDestination(for: PantryRoute.self) { route in
                    switch route {
                    case .pantry:
                        PantryView(
                            path: $path,
                            pantryService: sessionManager.pantryService!,
                            sseService: sessionManager.sseService!
                        )
                    }
                }
            }
        }
    }
}
