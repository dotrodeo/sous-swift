import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var backendUser: User? = nil
    @Published var household: Household? = nil

    var householdId: Int? {
        backendUser?.defaultHouseholdId
    }
}
