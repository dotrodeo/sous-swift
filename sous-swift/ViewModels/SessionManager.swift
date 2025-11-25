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
    var householdService: HouseholdServiceProtocol?
    var userService: UserServiceProtocol
    var recipeService: RecipeServiceProtocol?
    var pantryService: PantryServiceProtocol?
    var sseService: SSEServiceProtocol?

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
            isReady = false
            isLoggedIn = false
//            clearServices()
            return
        }
        
        var backendUser: User?
        isLoggedIn = true
        do {
            backendUser = try await userService.fetchUser()
        } catch {
            do {
                backendUser = try await userService.syncUser()
            } catch {
                print("Unable to fetch or sync user")
            }
        }
        
        if backendUser == nil {
            clearServices()
            isReady = false
        } else {
            appState.backendUser = backendUser
            appState.household = backendUser?.households.first(where: { household in
                household.id == backendUser!.defaultHouseholdId
            })
            registerServicesWithHousehold(
                householdId: backendUser!.defaultHouseholdId
            )
            isReady = true
        }
    }

    private func clearServices() {
        self.recipeService = nil
        self.pantryService = nil
        self.householdService = nil
        appState.backendUser = nil
        appState.household = nil
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
        self.householdService = HouseholdService(
            apiHelper: APIHelper(clerk: clerk),
            householdId: householdId
        )
        self.sseService = SSEService(householdId: householdId)
    }
}
