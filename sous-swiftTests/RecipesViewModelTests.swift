import XCTest
@testable import sous_swift

final class MockRecipeService: RecipeServiceProtocol {
    var recipes: [Recipe]
    var recipeById: [Int: Recipe] = [:]
    var tags: [RecipeTag] = []

    init(recipes: [Recipe]) { self.recipes = recipes }

    func fetchRecipes() async throws -> [Recipe] { recipes }
    func fetchRecipe(id: Int) async throws -> Recipe { recipeById[id]! }
    func upsertRecipe(patch: RecipePatch) async throws -> Recipe { throw NSError(domain: "test", code: 1) }
    func importRecipe(url: URL) async throws -> RecipeImport? { nil }
    func deleteRecipe(id: Int) async throws -> Void {}
    func getAllTags() async throws -> [RecipeTag] { tags }
    func completeRecipe(recipeId: Recipe.ID, completion: RecipeCompletion) async throws -> Void {}
}

final class MockPantryService: PantryServiceProtocol {
    let pantry: Pantry
    init(pantry: Pantry) { self.pantry = pantry }

    func fetchPantry() async throws -> Pantry { pantry }
    func upsertPantryItem(pantryId: Int, patch: PantryItemPatch) async throws -> PantryItem { throw NSError(domain: "test", code: 1) }
    func fetchCategories(pantryId: Int) async throws -> [ItemCategory] { [] }
    func upsertCategory(pantryId: Int, patch: ItemCategoryPatch) async throws -> ItemCategory { throw NSError(domain: "test", code: 1) }
    func updateCategorySortOrder(pantryId: Int, categoryIds: [Int]) async throws -> [ItemCategory]? { nil }
}

@MainActor
final class RecipesViewModelTests: XCTestCase {
    func decode<T: Decodable>(_ json: String) throws -> T {
        let data = Data(json.utf8)
        return try JSONDecoder().decode(T.self, from: data)
    }

    func makeRecipe(id: Int, name: String, tagName: String) throws -> Recipe {
        let json = """
        {
          "id": \(id),
          "name": "\(name)",
          "prepTime": null,
          "cookTime": null,
          "servings": null,
          "instructions": [],
          "createdAt": "",
          "updatedAt": "",
          "deletedAt": null,
          "ingredients": [],
          "tags": [{ "id": \(id), "name": "\(tagName)", "createdAt": "", "updatedAt": "", "recipes": null, "householdId": 0, "household": null }],
          "household": null,
          "householdId": 0,
          "source": null,
          "lastMade": null,
          "rating": 0,
          "timesMade": 0
        }
        """
        return try decode(json)
    }

    func makeEmptyPantry() throws -> Pantry {
        let json = """
        {
          "id": 0,
          "name": "Test Pantry",
          "isDefault": false,
          "createdAt": "",
          "updatedAt": "",
          "deletedAt": null,
          "householdId": 0,
          "household": null,
          "pantryItems": [],
          "itemCategories": []
        }
        """
        return try decode(json)
    }

    func testFilteringBySearchAndTags() async throws {
        let r1 = try makeRecipe(id: 1, name: "Apple Pie", tagName: "dessert")
        let r2 = try makeRecipe(id: 2, name: "Beef Stew", tagName: "dinner")

        let mockRecipeService = MockRecipeService(recipes: [r1, r2])
        let emptyPantry = try makeEmptyPantry()
        let mockPantryService = MockPantryService(pantry: emptyPantry)

        let vm = RecipesViewModel(recipeService: mockRecipeService, pantryService: mockPantryService)

        await vm.refresh()

        // Search for 'apple' should match r1
        vm.searchText = "apple"
        // Allow Combine pipeline to update
        try await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertEqual(vm.filteredRecipesPublished.map { $0.id }, [1])

        // Clear search and filter by tag
        vm.searchText = ""
        vm.selectedTags = ["dinner"]
        try await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertEqual(vm.filteredRecipesPublished.map { $0.id }, [2])
    }
}
