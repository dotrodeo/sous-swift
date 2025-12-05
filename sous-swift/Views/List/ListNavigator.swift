import SwiftData
import SwiftUI

enum ListRoute: Hashable {
    case list
}

struct ListNavigator: View {
    @State private var path = NavigationPath()
    @EnvironmentObject private var sessionManager: SessionManager

    var body: some View {
        if !sessionManager.isReady {
            ProgressView()
        } else {
            NavigationStack(path: $path) {
                ListView(
                    path: $path,
                    pantryService: sessionManager.pantryService!,
                    sseService: sessionManager.sseService!
                )
                .navigationDestination(for: ListRoute.self) { route in
                    switch route {
                    case .list:
                        ListView(
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
