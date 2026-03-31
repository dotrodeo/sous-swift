import Combine
import SwiftUI

enum ApplicationTab {
    case recipes
    case plan
    case pantry
    case list
    case settings
}

class AppState: ObservableObject {
    @Published var backendUser: User? = nil
    @Published var household: Household? = nil
    @Published var currentTab: ApplicationTab = .recipes
    @Published var recipePath = NavigationPath()
    @Published var planPath = NavigationPath()

    var householdId: Int? {
        backendUser?.defaultHouseholdId
    }
}
