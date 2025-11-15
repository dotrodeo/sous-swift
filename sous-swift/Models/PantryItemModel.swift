struct PantryItem: Identifiable, Decodable {
    let id: Int
    let name: String
    let isInStock: Bool
    let isFavorite: Bool
    let isInShoppingList: Bool
    let purchasedAt: String?
    let expiresAt: String?
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let categoryId: Int?
    let category: ItemCategory?
    let pantryId: Int
    let pantry: Pantry?
}
