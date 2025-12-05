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

func escapeApiBaseUrl(_ url: String?) -> String {
    guard let url else {
        fatalError("No base URL set")
    }

    return url.replacingOccurrences(of: "\\/", with: "/")
}

@MainActor
final class APIHelper: ObservableObject {
    var clerk: Clerk
    let baseUrl: URL?

    init(clerk: Clerk) {
        self.clerk = clerk
        self.baseUrl = URL(
            string: escapeApiBaseUrl(
                Bundle.main.object(forInfoDictionaryKey: "APIBaseURL")
                    as? String
            )
        )
    }

    func encodeURIComponent(_ url: URL) -> String {
        return url.absoluteString.addingPercentEncoding(
            withAllowedCharacters: .urlHostAllowed
        ) ?? ""
    }

    private func getToken() async throws -> String? {
        return try await clerk.session?.getToken()?.jwt
    }

    private func _makeRequest(
        method: String,
        endpoint: String,
        queryParameters: [String: String?] = [:],
        body: Encodable? = nil
    ) async throws -> Data {
        guard let baseUrl else {
            fatalError("No base URL set")
        }
        guard let token = try await getToken() else {
            throw URLError(.userAuthenticationRequired)
        }

        var qualifiedUrl = baseUrl.appendingPathComponent(endpoint)

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

        #if DEBUG
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON String: \(jsonString)")
            } else {
                print("Could not convert data to string.")
            }
        #endif

        guard
            let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode)
        else {
            throw URLError(.badServerResponse)
        }

        return data
    }

    private func makeRequest(
        method: String,
        endpoint: String,
        queryParameters: [String: String?] = [:],
        body: Encodable? = nil
    ) async throws {
        do {
            _ = try await _makeRequest(
                method: method,
                endpoint: endpoint,
                queryParameters: queryParameters,
                body: body
            )
        } catch {
            #if DEBUG
                print(error)
            #endif
            throw error
        }
    }

    private func makeRequest<T: Decodable>(
        method: String,
        endpoint: String,
        queryParameters: [String: String?] = [:],
        body: Encodable? = nil
    ) async throws -> T {
        do {
            let data = try await _makeRequest(
                method: method,
                endpoint: endpoint,
                queryParameters: queryParameters,
                body: body
            )
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            #if DEBUG
                print(error)
            #endif
            throw error
        }
    }

    func get<T: Decodable>(
        _ endpoint: String,
        queryParameters: [String: String?] = [:]
    ) async throws -> T {
        try await makeRequest(
            method: "GET",
            endpoint: endpoint,
            queryParameters: queryParameters
        )
    }

    func post<T: Decodable>(
        _ endpoint: String,
        body: Encodable? = nil
    ) async throws -> T {
        try await makeRequest(method: "POST", endpoint: endpoint, body: body)
    }
    
    func post(
        _ endpoint: String,
        body: Encodable? = nil
    ) async throws -> Void {
        try await makeRequest(method: "POST", endpoint: endpoint, body: body)
    }

    func delete(
        _ endpoint: String,
        queryParameters: [String: String?] = [:]
    ) async throws {
        guard let baseUrl else {
            fatalError("No base URL set")
        }
        guard let token = try await getToken() else {
            throw URLError(.userAuthenticationRequired)
        }

        var qualifiedUrl = baseUrl.appendingPathComponent(endpoint)
        if !queryParameters.isEmpty {
            qualifiedUrl =
                qualifiedUrl.appending(queryParameters: queryParameters)
                ?? qualifiedUrl
        }

        var request = URLRequest(url: qualifiedUrl)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (_, response) = try await URLSession.shared.data(for: request)

        guard
            let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode)
        else {
            throw URLError(.badServerResponse)
        }
    }
}
