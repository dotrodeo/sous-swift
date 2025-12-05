import SwiftData
import SwiftUI

enum ProfileRoute: Codable {
    case profile, editCategories, shareHousehold, joinHousehold
}

struct ProfileNavigator: View {
    @State private var path = NavigationPath()
    @EnvironmentObject private var sessionManager: SessionManager
    @EnvironmentObject private var appState: AppState

    var body: some View {
        if !sessionManager.isReady {
            ProgressView()
        } else {
            NavigationStack(path: $path) {
                ProfileView(
                    path: $path
                )
                .navigationDestination(for: ProfileRoute.self) { route in
                    switch route {
                    case .profile: ProfileView(path: $path)
                    case .editCategories:
                        EditCategoriesView(
                            path: $path,
                            pantryService: sessionManager.pantryService!,
                            sseService: sessionManager.sseService!
                        )
                    case .shareHousehold:
                        ShareHouseholdView(
                            path: $path,
                            household: appState.household!,
                            householdService: sessionManager.householdService!
                        )
                    case .joinHousehold:
                        JoinHouseholdView(
                            path: $path,
                            household: appState.household!,
                            householdService: sessionManager.householdService!
                        )
                    }
                }
            }
        }
    }
}
