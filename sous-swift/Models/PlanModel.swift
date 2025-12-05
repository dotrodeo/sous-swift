struct Plan: Identifiable, Decodable, Equatable {
    let id: Int
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let planDays: [PlanDay]
    let household: Household?
    let householdId: Int

    static func == (lhs: Plan, rhs: Plan) -> Bool {
        lhs.id == rhs.id
    }
}
