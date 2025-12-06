struct Recipe: Identifiable, Decodable, Equatable {
    let id: Int
    let name: String
    let prepTime: String?
    let cookTime: String?
    let servings: String?
    let instructions: [String]?
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let ingredients: [Ingredient]?
    let tags: [RecipeTag]?
    let household: Household?
    let householdId: Int

    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        lhs.id == rhs.id
    }

    init(
        id: Int,
        name: String,
        prepTime: String? = nil,
        cookTime: String? = nil,
        servings: String? = nil,
        instructions: [String]? = nil,
        createdAt: String,
        updatedAt: String,
        deletedAt: String? = nil,
        ingredients: [Ingredient]? = nil,
        tags: [RecipeTag]? = nil,
        household: Household? = nil,
        householdId: Int
    ) {
        self.id = id
        self.name = name
        self.prepTime = prepTime
        self.cookTime = cookTime
        self.servings = servings
        self.instructions = instructions
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.ingredients = ingredients
        self.tags = tags
        self.household = household
        self.householdId = householdId
    }
}

struct RecipePatch: Encodable {
    var id: Int?
    var name: String?
    var prepTime: String?
    var cookTime: String?
    var servings: String?
    var ingredients: [String]?
    var instructions: [String]?
    var tags: [RecipeTagPatch]?
    var deletedAt: String?
}

struct RecipeImport: Decodable {
    let name: String?
    let prepTime: String?
    let cookTime: String?
    let servings: String?
    let ingredients: [String]?
    let instructions: [String]?
}

struct RecipeCompletion: Codable {
    let recipeId: Recipe.ID
    let rating: Rating?
    let finishedPantryItems: [PantryItem.ID]
}
