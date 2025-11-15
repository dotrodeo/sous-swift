import Foundation

protocol RecipeServiceProtocol {
    func fetchRecipes() async throws -> [Recipe]
    func fetchRecipe(id: Int) async throws -> Recipe
    func createRecipe(title: String) async throws -> Recipe
}

final class RecipeService: RecipeServiceProtocol {
    private let householdId: Int
    private let baseURL = URL(string: "http://localhost:8080")!
    
    init (householdId: Int) {
        self.householdId = householdId
    }

    func fetchRecipes() async throws -> [Recipe] {
        return try await APIHelper.get(
            baseURL.appendingPathComponent("/household/\(householdId)/recipes")
        )
    }
    
    func fetchRecipe(id: Int) async throws -> Recipe {
        return try await APIHelper.get(
            baseURL.appendingPathComponent("/household/\(householdId)/recipes/\(id)")
        )
    }

    func createRecipe(title: String) async throws -> Recipe {
        return try await APIHelper.post(
            baseURL.appendingPathComponent("/household/\(householdId)/recipes/1"),
            body: []
        )
    }
}
