import Clerk
import Combine
import Foundation
import SwiftUI

class SessionManagerHolder: ObservableObject {
    @Published var manager: SessionManager?

    func loadIfNeeded(
        clerk: Clerk,
        appState: AppState
    ) {
        guard manager == nil else { return }
        manager = SessionManager(
            clerk: clerk,
            appState: appState
        )
    }
}

class SessionManager: ObservableObject {
    let clerk: Clerk
    private let appState: AppState
    var userService: UserServiceProtocol
    var recipeService: RecipeServiceProtocol?
    var pantryService: PantryServiceProtocol?

    private var cancellables = Set<AnyCancellable>()
    private var authListener: (() -> Void)?

    @Published var isReady = false
    @Published var isLoggedIn = false

    init(clerk: Clerk, appState: AppState) {
        self.clerk = clerk
        self.appState = appState
        self.userService = UserService(apiHelper: APIHelper(clerk: clerk))

        observeAuthEvents()
    }

    private func observeAuthEvents() {
        Task { @MainActor in
            for await _ in clerk.authEventEmitter.events {
                await handleAuthEvent()
            }
        }
    }

    @MainActor
    func handleAuthEvent() async {
        guard clerk.session != nil, clerk.user != nil else {
            clearServices()
            isReady = false
            isLoggedIn = false
            return
        }

        isLoggedIn = true
        do {
            let backendUser = try await userService.fetchUser()
            appState.backendUser = backendUser
            registerServicesWithHousehold(
                householdId: backendUser.defaultHouseholdId
            )
            isReady = true
        } catch {
            print("Failed to fetch backend user:", error)
            clearServices()
            isReady = false
        }
    }

    private func clearServices() {
        self.recipeService = nil
        self.pantryService = nil
        appState.backendUser = nil
        isLoggedIn = false
    }

    func registerServicesWithHousehold(householdId: Household.ID) {
        self.recipeService = RecipeService(
            apiHelper: APIHelper(clerk: clerk),
            householdId: householdId
        )
        self.pantryService = PantryService(
            apiHelper: APIHelper(clerk: clerk),
            householdId: householdId
        )
    }
}
