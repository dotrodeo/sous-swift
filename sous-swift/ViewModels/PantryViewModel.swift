import Combine
import SwiftUI

@MainActor
class PantryViewModel: ObservableObject {
    @Published var pantry: Pantry? = nil
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let pantryApi: PantryServiceProtocol

    init(pantryApi: PantryServiceProtocol) {
        self.pantryApi = pantryApi
    }

    func loadPantry() async {
        isLoading = true
        errorMessage = nil

        do {
            pantry = try await pantryApi.fetchPantry()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
