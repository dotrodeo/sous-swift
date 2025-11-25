import Combine
import SwiftUI

@MainActor
final class HouseholdViewModel: ObservableObject {
    @Published private(set) var household: Household?

    private let householdService: HouseholdServiceProtocol

    init(
        household: Household,
        householdService: HouseholdServiceProtocol
    ) {
        self.household = household
        self.householdService = householdService
    }

    func joinHousehold(joinToken: String) async {
        do {
            _ = try await householdService.joinHousehold(joinToken: joinToken)
        } catch {
            print("Failed to join household: \(error)")
        }
    }
}
