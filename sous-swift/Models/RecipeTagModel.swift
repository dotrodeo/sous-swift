struct RecipeTag: Identifiable, Decodable {
    let id: Int
    let name: String
    let createdAt: String
    let updatedAt: String
    let recipes: [Recipe]?
    let householdId: Int
    let household: Household?
}

struct RecipeTagPatch: Encodable {
    let id: Int?
    let name: String?
    
    init(id: Int? = nil, name: String?) {
        self.id = id
        self.name = name
    }
}

extension RecipeTagPatch {
    init(from tag: RecipeTag) {
        self.id = tag.id
        self.name = tag.name
    }
}
