struct User: Identifiable, Decodable {
    let id: String
    let clerkId: String
    let email: String?
    let name: String?
    let themePreference: String?
    let defaultHouseholdId: Int?
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let households: [Household]
}
