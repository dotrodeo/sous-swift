import Foundation

protocol PantryServiceProtocol {
    func fetchPantry() async throws -> Pantry
    func upsertPantryItem(pantryId: Int, patch: PantryItemPatch) async throws
        -> PantryItem
    func fetchCategories(pantryId: Int) async throws -> [ItemCategory]
    func upsertCategory(pantryId: Int, patch: ItemCategoryPatch) async throws
        -> ItemCategory
    func updateCategorySortOrder(pantryId: Int, categoryIds: [Int]) async throws
        -> [ItemCategory]?
}

final class PantryService: PantryServiceProtocol {
    private let householdId: Int
    private let apiHelper: APIHelper

    init(apiHelper: APIHelper, householdId: Int) {
        self.apiHelper = apiHelper
        self.householdId = householdId
    }

    func fetchPantry() async throws -> Pantry {
        return try await apiHelper.get(
            "/household/\(householdId)/pantry"
        )
    }

    func upsertPantryItem(pantryId: Int, patch: PantryItemPatch) async throws
        -> PantryItem
    {
        return try await apiHelper.post(
            "/household/\(householdId)/pantry/\(pantryId)",
            body: patch
        )
    }

    func fetchCategories(pantryId: Int) async throws -> [ItemCategory] {
        return try await apiHelper.get(
            "/household/\(householdId)/pantry/\(pantryId)/category"
        )
    }

    func upsertCategory(pantryId: Int, patch: ItemCategoryPatch) async throws
        -> ItemCategory
    {
        return try await apiHelper.post(
            "/household/\(householdId)/pantry/\(pantryId)/category",
            body: patch
        )
    }

    func updateCategorySortOrder(pantryId: Int, categoryIds: [Int]) async throws
        -> [ItemCategory]?
    {
        try await apiHelper.post(
            "/household/\(householdId)/pantry/\(pantryId)/category/sort-order",
            body: categoryIds
        )
    }
}
