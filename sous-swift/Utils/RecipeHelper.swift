import Foundation

struct RecipeHelper {
    private init() {}

    static func getAvailableIngredients(
        recipe: Recipe,
        pantryItems: [PantryItem]?
    ) -> [PantryItem] {
        guard let pantryItems = pantryItems, !pantryItems.isEmpty else {
            return []
        }

        let search = FuzzySearch(items: pantryItems, keyPath: \.name)
        var availableIngredients: [PantryItem] = []

        guard let ingredients = recipe.ingredients else { return [] }

        for ingredient in ingredients {
            guard let itemName = ingredient.item else { continue }

            let results = search.search(itemName)
            if let topResult = results.first, topResult.score <= 0.5,
                topResult.item.isInStock
            {
                availableIngredients.append(topResult.item)
            }
        }

        return availableIngredients
    }
}
