import Combine
import SwiftUI

@MainActor
final class PlanViewModel: ObservableObject {
    @Published var plan: Plan? = nil
    @Published var futurePlanDays: [PlanDay] = []
    @Published var recipes: [Recipe] = []    
    @Published var pantry: Pantry? = nil
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var searchText: String? = ""

    private let planService: PlanServiceProtocol
    private let recipeService: RecipeServiceProtocol
    private let pantryService: PantryServiceProtocol

    init(
        planService: PlanServiceProtocol,
        recipeService: RecipeServiceProtocol,
        pantryService: PantryServiceProtocol
    ) {
        self.planService = planService
        self.recipeService = recipeService
        self.pantryService = pantryService
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil

        do {
            plan = try await planService.getPlan()
            futurePlanDays = getFuturePlanDays()
            recipes = try await recipeService.fetchRecipes()
            pantry = try await pantryService.fetchPantry()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func getFuturePlanDays() -> [PlanDay] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let todayStr = DateHelper.toString(today)

        func planDate(from planDay: String?) -> Date {
            let date = DateHelper.fromString(planDay ?? todayStr) ?? today
            return calendar.startOfDay(for: date)
        }

        return plan?.planDays
            .filter {
                $0.date == nil
                    || planDate(from: $0.date) >= today
            } ?? []
    }
    
    func sortRecipes(_ r: [Recipe]) -> [Recipe]{
        return r.sorted {
            $0.name.lowercased() < $1.name.lowercased()
        }
    }

    func planRecipes(planDayId: Int, recipeIds: [Int]) async {
        isLoading = true
        errorMessage = nil

        do {
            _ = try await planService.addRecipesToPlan(
                planDayId: planDayId,
                recipeIds: recipeIds
            )
            await refresh()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
    
    func unplanRecipe(planDayId: PlanDay.ID, recipeId: Recipe.ID) async {
        isLoading = true
        errorMessage = nil

        do {
            _ = try await planService.removeRecipesFromPlan(
                planDayId: planDayId,
                recipeId: recipeId
            )
            await refresh()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
    
    func addPlanDay(date: String) async {
        guard let plan else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await planService.addPlanDay(planId: plan.id, date: date)
            await refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func matchToPantryItem(_ ingredient: String) -> PantryItem? {
        guard let pantry else { return nil }
        let search = FuzzySearch(items: pantry.pantryItems, keyPath: \.name)
        let results = search.search(ingredient)

        if results.count >= 1
            && results[0].score <= Constants.FUZZY_SEARCH_THRESHOLD
        {
            return results[0].item
        }

        return nil
    }

    func completeRecipe(id: Recipe.ID, completion: RecipeCompletion) async {
        isLoading = true
        do {
            _ = try await recipeService.completeRecipe(
                recipeId: id,
                completion: completion
            )
            await refresh()
        } catch {
            print(error.localizedDescription)
            isLoading = false
        }
    }
}

