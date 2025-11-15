struct ItemCategory: Identifiable, Decodable {
    let id: Int
    let name: String
    let sortOrder: Int
    let icon: String?
    let isNonFood: Bool
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let pantryItems: [PantryItem]?
    let pantryId: Int
    let pantry: Pantry?
}
