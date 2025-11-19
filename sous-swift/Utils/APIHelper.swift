import Clerk
import Combine
import Foundation
import SwiftUI

extension URL {
    /// Returns a new URL by adding the given query parameters
    func appending(queryParameters: [String: String?]) -> URL? {
        guard
            var components = URLComponents(
                url: self,
                resolvingAgainstBaseURL: false
            )
        else { return nil }
        var queryItems = components.queryItems ?? []
        queryItems.append(
            contentsOf: queryParameters.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        )
        components.queryItems = queryItems
        return components.url
    }
}

struct AnyEncodable: Encodable {
    private let encodeFunc: (Encoder) throws -> Void

    init(_ wrapped: Encodable) {
        encodeFunc = wrapped.encode
    }

    func encode(to encoder: Encoder) throws {
        try encodeFunc(encoder)
    }
}

@MainActor
final class APIHelper: ObservableObject {
    var clerk: Clerk

    init(clerk: Clerk) {
        self.clerk = clerk
    }

    func encodeURIComponent(_ url: URL) -> String {
        return url.absoluteString.addingPercentEncoding(
            withAllowedCharacters: .urlHostAllowed
        ) ?? ""
    }

    private func getToken() async throws -> String? {
        return try await clerk.session?.getToken()?.jwt
    }

    private func makeRequest<T: Decodable>(
        method: String,
        url: URL,
        queryParameters: [String: String?] = [:],
        body: Encodable? = nil
    ) async throws -> T {

        guard let token = try await getToken() else {
            throw URLError(.userAuthenticationRequired)
        }

        var qualifiedUrl = url

        if !queryParameters.isEmpty {
            qualifiedUrl =
                qualifiedUrl.appending(queryParameters: queryParameters)
                ?? qualifiedUrl
        }

        var request = URLRequest(url: qualifiedUrl)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        if let body {
            request.addValue(
                "application/json",
                forHTTPHeaderField: "Content-Type"
            )
            request.httpBody = try JSONEncoder().encode(AnyEncodable(body))
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard
            let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode)
        else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }

    func get<T: Decodable>(
        _ url: URL,
        queryParameters: [String: String?] = [:]
    ) async throws -> T {
        try await makeRequest(
            method: "GET",
            url: url,
            queryParameters: queryParameters
        )
    }

    func post<T: Decodable, Body: Encodable>(
        _ url: URL,
        body: Body
    ) async throws -> T {
        try await makeRequest(method: "POST", url: url, body: body)
    }

}
