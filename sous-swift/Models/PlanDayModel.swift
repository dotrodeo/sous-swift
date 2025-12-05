struct PlanDay: Identifiable, Decodable {
    let id: Int
    let date: String?
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let recipes: [Recipe]
    let plan: Plan?
    let planId: Int
}
