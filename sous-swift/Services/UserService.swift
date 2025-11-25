import Foundation

protocol UserServiceProtocol {
    func fetchUser() async throws -> User
    func syncUser() async throws -> User
}

final class UserService: UserServiceProtocol {
    private let apiHelper: APIHelper

    init(apiHelper: APIHelper) {
        self.apiHelper = apiHelper
    }

    func fetchUser() async throws -> User {
        return try await apiHelper.get("/user")
    }
    
    func syncUser() async throws -> User {
        return try await apiHelper.post("/user/sync")
    }
}
