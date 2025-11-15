import Foundation

protocol PantryServiceProtocol {
    func fetchPantry() async throws -> Pantry
    func upsertPantryItem(pantryId: Int) async throws -> PantryItem
}

final class PantryService: PantryServiceProtocol {
    private let householdId: Int
    private let baseURL = URL(string: "http://localhost:8080")!
    
    init (householdId: Int) {
        self.householdId = householdId
    }

    func fetchPantry() async throws -> Pantry {
        return try await APIHelper.get(
            baseURL.appendingPathComponent("/household/\(householdId)/pantry")
        )
    }

    func upsertPantryItem(pantryId: Int) async throws -> PantryItem {
        return try await APIHelper.post(
            baseURL.appendingPathComponent("/household/\(householdId)/pantry/\(pantryId)"),
            body: []
        )
    }
}
