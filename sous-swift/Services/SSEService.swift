import EventSource
import Foundation

enum SSEMessageType: String, Codable {
    case recipeUpdate = "recipe_update"
    case recipeDelete = "recipe_delete"
    case pantryUpdate = "pantry_update"
    case categoryUpdate = "category_update"
    case userUpdate = "user_update"
}

struct SSEEvent: Codable {
    let type: SSEMessageType?
    let from: String?
    let message: String?

    private enum CodingKeys: String, CodingKey {
        case type
        case from
        case message
    }
}

protocol SSEServiceProtocol {
    func stream() -> AsyncStream<SSEEvent>
}

class SSEService: SSEServiceProtocol {
    private var dataTask: EventSource.DataTask?
    private let householdId: Int
    private let baseUrl = URL(
        string: escapeApiBaseUrl(
            Bundle.main.object(forInfoDictionaryKey: "APIBaseURL")
                as? String
        )
    )
    private let eventEndpoint: URL

    init(householdId: Int) {
        guard let baseUrl else {
            fatalError("APIBaseURL has no value")
        }
        self.householdId = householdId
        self.eventEndpoint = baseUrl.appendingPathComponent(
            "/events/\(householdId)"
        )
    }

    func stream() -> AsyncStream<SSEEvent> {
        AsyncStream { continuation in
            let eventSource = EventSource()
            let request = URLRequest(url: eventEndpoint)
            let task = eventSource.dataTask(for: request)
            self.dataTask = task

            Task {
                for try await event in task.events() {
                    switch event {
                    case .open:
                        #if DEBUG
                            print("SSE connected")
                        #endif

                    case .event(let e):
                        guard let data = e.data?.data(using: .utf8) else {
                            break
                        }

                        Task {
                            do {
                                let decoded = try JSONDecoder().decode(
                                    SSEEvent.self,
                                    from: data
                                )
                                continuation.yield(decoded)
                            } catch {
                                if let raw = String(data: data, encoding: .utf8)
                                {
                                    #if DEBUG
                                        print(
                                            "Failed to decode SSEEvent:",
                                            raw,
                                            error
                                        )
                                    #endif
                                }
                            }
                        }

                    case .error(let error):
                        #if DEBUG
                            print("SSE error:", error.localizedDescription)
                        #endif

                    case .closed:
                        #if DEBUG
                            print("SSE closed")
                        #endif
                        continuation.finish()
                    }
                }
            }

            continuation.onTermination = { @Sendable _ in
                continuation.finish()
            }
        }
    }
}
