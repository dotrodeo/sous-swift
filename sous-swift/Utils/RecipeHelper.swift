import Foundation

struct RecipeHelper {
    static private var ratioCache: [Int: Double] = [:]

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
            if let topResult = results.first, topResult.score <= Constants.FUZZY_SEARCH_THRESHOLD,
                topResult.item.isInStock
            {
                availableIngredients.append(topResult.item)
            }
        }

        return availableIngredients
    }
    
    static func ratio(for recipe: Recipe, pantryItems: [PantryItem]) -> Double {
        if let cached = ratioCache[recipe.id] {
            return cached
        }

        guard let ingredients = recipe.ingredients else {
            ratioCache[recipe.id] = 0
            return 0
        }

        let available = RecipeHelper.getAvailableIngredients(
            recipe: recipe,
            pantryItems: pantryItems
        )

        let val = Double(available.count) / Double(ingredients.count)
        ratioCache[recipe.id] = val
        return val
    }
    
    static func clearRatioCache() -> Void {
        ratioCache.removeAll()
    }
}
