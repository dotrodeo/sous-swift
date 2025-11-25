import Foundation

protocol RecipeServiceProtocol {
    func fetchRecipes() async throws -> [Recipe]
    func fetchRecipe(id: Int) async throws -> Recipe
    func upsertRecipe(patch: RecipePatch) async throws -> Recipe
    func importRecipe(url: URL) async throws -> RecipeImport?
    func deleteRecipe(id: Int) async throws -> Void
}

final class RecipeService: RecipeServiceProtocol {
    private let householdId: Int
    private let apiHelper: APIHelper

    init(apiHelper: APIHelper, householdId: Int) {
        self.apiHelper = apiHelper
        self.householdId = householdId
    }

    func fetchRecipes() async throws -> [Recipe] {
        return try await apiHelper.get("/household/\(householdId)/recipes")
    }
    
    func fetchRecipe(id: Int) async throws -> Recipe {
        return try await apiHelper.get("/household/\(householdId)/recipes/\(id)")
    }
    
    func upsertRecipe(patch: RecipePatch) async throws -> Recipe {
        return try await apiHelper.post(
            "/household/\(householdId)/recipes",
            body: patch
        )
    }
    
    func importRecipe(url: URL) async throws -> RecipeImport? {
        let res: RecipeImport? = try await apiHelper.get(
            "/household/\(householdId)/recipes/scrape",
            queryParameters: ["url": url.absoluteString]
        )
        return res
    }
    
    func deleteRecipe(id: Int) async throws -> Void {
        try await apiHelper.delete("/household/\(householdId)/recipes/\(id)")
    }
}

