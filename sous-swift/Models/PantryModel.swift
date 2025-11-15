struct Pantry: Identifiable, Decodable {
    let id: Int
    let name: String
    let isDefault: Bool
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let householdId: Int
    let household: Household?
    let pantryItems: [PantryItem]?
    let itemCategories: [ItemCategory]?
}
