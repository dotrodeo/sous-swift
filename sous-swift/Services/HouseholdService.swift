import Foundation

protocol HouseholdServiceProtocol {
    func joinHousehold(joinToken: String) async throws -> Household
}

struct JoinHouseholdBody: Encodable {
    var joinToken: String
}

final class HouseholdService: HouseholdServiceProtocol {
    private let apiHelper: APIHelper
    private let householdId: Int

    init(apiHelper: APIHelper, householdId: Int) {
        self.apiHelper = apiHelper
        self.householdId = householdId
    }

    func joinHousehold(joinToken: String) async throws -> Household {
        return try await apiHelper.post(
            "/household/\(householdId)/join",
            body: JoinHouseholdBody(joinToken: joinToken)
        )
    }
}
