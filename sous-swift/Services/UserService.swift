import Foundation

protocol UserServiceProtocol {
    func fetchUser() async throws -> User
}

final class UserService: UserServiceProtocol {
    private let baseURL = URL(string: "https://soupi.up.railway.app")!
    private let apiHelper: APIHelper

    init(apiHelper: APIHelper) {
        self.apiHelper = apiHelper
    }

    func fetchUser() async throws -> User {
        return try await apiHelper.get(
            baseURL.appendingPathComponent("/user")
        )
    }
}
