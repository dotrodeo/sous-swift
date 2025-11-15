import Foundation

struct RecipeHelper {
    private init() {}

    static func getAvailableIngredients(recipe: Recipe, pantryItems: [PantryItem]?) -> [PantryItem] {
        guard let pantryItems = pantryItems, !pantryItems.isEmpty else {
            return []
        }
        
        var availableIngredients: [PantryItem] = []
        
        for ingredient in recipe.ingredients ?? [] {
            let name = ingredient.item ?? ""
            
            // Find the first pantry item whose name matches the ingredient
            if let pantryItem = pantryItems.first(where: { $0.name.localizedCaseInsensitiveContains(name) }) {
                if pantryItem.isInStock {
                    availableIngredients.append(pantryItem)
                }
            }
        }
        
        return availableIngredients
    }
}
