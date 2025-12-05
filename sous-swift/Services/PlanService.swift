import Foundation

protocol PlanServiceProtocol {
    func getPlan() async throws -> Plan
    func addPlanDay(planId: Plan.ID, date: String) async throws -> Plan
    func addRecipesToPlan(planDayId: Int, recipeIds: [Int]) async throws
    func removeRecipesFromPlan(planDayId: PlanDay.ID, recipeId: Recipe.ID) async throws
}

final class PlanService: PlanServiceProtocol {
    private let apiHelper: APIHelper
    private let householdId: Int

    init(apiHelper: APIHelper, householdId: Int) {
        self.apiHelper = apiHelper
        self.householdId = householdId
    }

    func getPlan() async throws -> Plan {
        return try await apiHelper.get("/household/\(householdId)/plan")
    }
    
    struct AddPlanDayBody: Encodable {
        let planId: Int
        let date: String
    }
    
    func addPlanDay(planId: Plan.ID, date: String) async throws -> Plan {
        try await apiHelper.post(
            "/household/\(householdId)/plan/day",
            body: AddPlanDayBody(planId: planId, date: date)
        )
    }

    func addRecipesToPlan(planDayId: Int, recipeIds: [Int]) async throws {
        try await apiHelper.post(
            "/household/\(householdId)/plan/day/\(planDayId)/recipes",
            body: recipeIds
        )
    }
    
    func removeRecipesFromPlan(planDayId: PlanDay.ID, recipeId: Recipe.ID) async throws {
        try await apiHelper.delete(
            "/household/\(householdId)/plan/day/\(planDayId)/recipes/\(recipeId)"
        )
    }
}
