import Foundation

protocol PantryServiceProtocol {
    func fetchPantry() async throws -> Pantry
    func upsertPantryItem(pantryId: Int, patch: PantryItemPatch) async throws -> PantryItem
    func fetchCategories(pantryId: Int) async throws -> [ItemCategory]
}

final class PantryService: PantryServiceProtocol {
    private let householdId: Int
    private let baseURL = URL(string: "https://soupi.up.railway.app")!
    private let apiHelper: APIHelper

    init(apiHelper: APIHelper, householdId: Int) {
        self.apiHelper = apiHelper
        self.householdId = householdId
    }

    func fetchPantry() async throws -> Pantry {
        return try await apiHelper.get(
            baseURL.appendingPathComponent("/household/\(householdId)/pantry")
        )
    }

    func upsertPantryItem(pantryId: Int, patch: PantryItemPatch) async throws -> PantryItem {
        return try await apiHelper.post(
            baseURL.appendingPathComponent("/household/\(householdId)/pantry/\(pantryId)"),
            body: patch
        )
    }
    
    func fetchCategories(pantryId: Int) async throws -> [ItemCategory] {
        return try await apiHelper.get(
            baseURL.appendingPathComponent("/household/\(householdId)/pantry/\(pantryId)/category")
        )
    }
}
