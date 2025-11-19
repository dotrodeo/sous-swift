struct Household: Identifiable, Decodable {
    let id: Int
    let name: String
    let joinToken: String
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let members: [User]?
    let pantries: [Pantry]?
    let recipes: [Recipe]?
    let recipeTags: [RecipeTag]?
}
