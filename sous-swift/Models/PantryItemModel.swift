import Foundation

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

extension PantryItem {
    func copy(
        id: Int? = nil,
        name: String? = nil,
        isInShoppingList: Bool? = nil,
        isInStock: Bool? = nil,
        isFavorite: Bool? = nil,
        purchasedAt: String? = nil,
        expiresAt: String? = nil,
        deletedAt: String? = nil,
        categoryId: Int? = nil,
        category: ItemCategory? = nil
    ) -> PantryItem {
        let newCategory = category ?? self.category
        let newCategoryId = categoryId ?? newCategory?.id ?? self.categoryId

        return PantryItem(
            id: id ?? self.id,
            name: name ?? self.name,
            isInStock: isInStock ?? self.isInStock,
            isFavorite: isFavorite ?? self.isFavorite,
            isInShoppingList: isInShoppingList ?? self.isInShoppingList,
            purchasedAt: purchasedAt ?? self.purchasedAt,
            expiresAt: expiresAt ?? self.expiresAt,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            deletedAt: deletedAt ?? self.deletedAt,
            categoryId: newCategoryId,
            category: newCategory,
            pantryId: self.pantryId,
            pantry: self.pantry
        )
    }
}

struct PantryItemPatch: Encodable, Identifiable {
    var id: Int?
    var name: String?
    var isInStock: Bool?
    var isFavorite: Bool?
    var isInShoppingList: Bool?
    var purchasedAt: String?
    var expiresAt: String?
    var deletedAt: String?
    var categoryId: Int?
    var _uid: UUID

    init(
        id: Int? = nil,
        name: String? = nil,
        isInStock: Bool? = nil,
        isFavorite: Bool? = nil,
        isInShoppingList: Bool? = nil,
        purchasedAt: String? = nil,
        expiresAt: String? = nil,
        deletedAt: String? = nil,
        categoryId: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.isInStock = isInStock
        self.isFavorite = isFavorite
        self.isInShoppingList = isInShoppingList
        self.purchasedAt = purchasedAt
        self.expiresAt = expiresAt
        self.deletedAt = deletedAt
        self.categoryId = categoryId
        self._uid = UUID()
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case isInStock
        case isFavorite
        case isInShoppingList
        case purchasedAt
        case deletedAt
        case categoryId
        // Intentionally omit _uid so it is not encoded
    }
}

extension PantryItemPatch {
    init(from item: PantryItem) {
        self.id = item.id
        self.name = item.name
        self.isInStock = item.isInStock
        self.isFavorite = item.isFavorite
        self.isInShoppingList = item.isInShoppingList
        self.purchasedAt = item.purchasedAt
        self.expiresAt = item.expiresAt
        self.deletedAt = item.deletedAt
        self.categoryId = item.categoryId
        self._uid = UUID()
    }
}
