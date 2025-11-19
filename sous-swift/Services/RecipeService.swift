import Foundation

protocol RecipeServiceProtocol {
    func fetchRecipes() async throws -> [Recipe]
    func fetchRecipe(id: Int) async throws -> Recipe
    func upsertRecipe(patch: RecipePatch) async throws -> Recipe
    func importRecipe(url: URL) async throws -> RecipeImport?
}

final class RecipeService: RecipeServiceProtocol {
    private let householdId: Int
    private let baseURL = URL(string: "https://soupi.up.railway.app")!
    private let apiHelper: APIHelper

    init(apiHelper: APIHelper, householdId: Int) {
        self.apiHelper = apiHelper
        self.householdId = householdId
    }

    func fetchRecipes() async throws -> [Recipe] {
        return try await apiHelper.get(
            baseURL.appendingPathComponent("/household/\(householdId)/recipes")
        )
    }
    
    func fetchRecipe(id: Int) async throws -> Recipe {
        return try await apiHelper.get(
            baseURL.appendingPathComponent("/household/\(householdId)/recipes/\(id)")
        )
    }
    
    func upsertRecipe(patch: RecipePatch) async throws -> Recipe {
        return try await apiHelper.post(
            baseURL.appendingPathComponent("/household/\(householdId)/recipes"),
            body: patch
        )
    }
    
    func importRecipe(url: URL) async throws -> RecipeImport? {
        let res: RecipeImport? = try await apiHelper.get(
            baseURL.appendingPathComponent("/household/\(householdId)/recipes/scrape"),
            queryParameters: ["url": url.absoluteString]
        )
        return res
    }
}
