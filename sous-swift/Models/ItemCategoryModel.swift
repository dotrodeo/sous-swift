import Foundation

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

extension ItemCategory {
    func copy(_ patch: ItemCategoryPatch) -> ItemCategory {
        copy(
            id: patch.id,
            name: patch.name,
            sortOrder: self.sortOrder,
            icon: patch.icon,
            isNonFood: patch.isNonFood,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            deletedAt: patch.deletedAt,
            pantryItems: self.pantryItems,
            pantryId: patch.pantryId,
            pantry: self.pantry,
        )
    }
    func copy(
         id: Int? = nil,
         name: String? = nil,
         sortOrder: Int? = nil,
         icon: String? = nil,
         isNonFood: Bool? = nil,
         createdAt: String? = nil,
         updatedAt: String? = nil,
         deletedAt: String? = nil,
         pantryItems: [PantryItem]? = nil,
         pantryId: Int? = nil,
         pantry: Pantry? = nil,
    ) -> ItemCategory {

        return ItemCategory(
            id: id ?? self.id,
            name: name ?? self.name,
            sortOrder: sortOrder ?? self.sortOrder,
            icon: icon ?? self.icon,
            isNonFood: isNonFood ?? self.isNonFood,
            createdAt: createdAt ?? self.createdAt,
            updatedAt: updatedAt ?? self.updatedAt,
            deletedAt: deletedAt ?? self.deletedAt,
            pantryItems: pantryItems ?? self.pantryItems,
            pantryId: pantryId ?? self.pantryId,
            pantry: pantry ?? self.pantry,
        )
    }
}

struct ItemCategoryPatch: Encodable, Identifiable {
    var id: Int?
    var name: String?
    var icon: String?
    var isNonFood: Bool?
    var deletedAt: String?
    var pantryId: Int?
    var _uid: UUID
    
    init(
         id: Int? = nil,
         name: String? = nil,
         icon: String? = nil,
         isNonFood: Bool? = nil,
         deletedAt: String? = nil,
         pantryId: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.isNonFood = isNonFood
        self.deletedAt = deletedAt
        self.pantryId = pantryId
        self._uid = UUID()
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case icon
        case isNonFood
        case deletedAt
        case pantryId
    }
}

extension ItemCategoryPatch {
    init(from item: ItemCategory) {
        self.id = item.id
        self.name = item.name
        self.icon = item.icon
        self.isNonFood = item.isNonFood
        self.deletedAt = item.deletedAt
        self.pantryId = item.pantryId
        self._uid = UUID()
    }
}
