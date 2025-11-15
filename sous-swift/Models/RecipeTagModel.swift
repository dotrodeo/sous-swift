struct RecipeTag: Identifiable, Decodable {
    let id: Int
    let name: String
    let createdAt: String
    let updatedAt: String
    let recipes: [Recipe]?
    let householdId: Int
    let household: Household?
}
