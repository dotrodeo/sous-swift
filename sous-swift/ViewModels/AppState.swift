import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var backendUser: User? = nil

    var householdId: Int? {
        backendUser?.defaultHouseholdId
    }
}
