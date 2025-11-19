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
}

struct RecipePatch: Encodable {
    let id: Int?
    let name: String?
    let prepTime: String?
    let cookTime: String?
    let servings: String?
    let instructions: [String]?
    let deletedAt: String?
    let ingredients: [String]?
    let tags: [String]?
}

struct RecipeImport: Decodable {
    let name: String?
    let prepTime: String?
    let cookTime: String?
    let servings: String?
    let ingredients: [String]?
    let instructions: [String]?
}
