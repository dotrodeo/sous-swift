import SwiftUI

struct Ingredient: Identifiable, Decodable {
    let id: Int
    let sentence: String
    let item: String?
    let size: String?
    let amount: PrismaDecimal?
    let unit: String?
    let preparation: String?
    let json: JSONValue?
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let recipe: Recipe?
    let recipeId: Int

    init(
        id: Int,
        sentence: String,
        item: String? = nil,
        size: String? = nil,
        amount: PrismaDecimal? = nil,
        unit: String? = nil,
        preparation: String? = nil,
        json: JSONValue? = nil,
        createdAt: String,
        updatedAt: String,
        deletedAt: String? = nil,
        recipe: Recipe? = nil,
        recipeId: Int
    ) {
        self.id = id
        self.sentence = sentence
        self.item = item
        self.size = size
        self.amount = amount
        self.unit = unit
        self.preparation = preparation
        self.json = json
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.recipe = recipe
        self.recipeId = recipeId
    }
}

struct PrismaDecimal: Decodable {
    let s: Int
    let e: Int
    let d: [Int]

    var value: Double {
        let digits = d.map { String($0) }.joined()
        let decimalValue = Double(digits) ?? 0
        return Double(s) * decimalValue
            * pow(10, Double(e - (digits.count - 1)))
    }
}

enum JSONValue: Decodable {
    case string(String)
    case number(Double)
    case object([String: JSONValue])
    case array([JSONValue])
    case bool(Bool)
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let b = try? container.decode(Bool.self) {
            self = .bool(b)
        } else if let n = try? container.decode(Double.self) {
            self = .number(n)
        } else if let s = try? container.decode(String.self) {
            self = .string(s)
        } else if let o = try? container.decode([String: JSONValue].self) {
            self = .object(o)
        } else if let a = try? container.decode([JSONValue].self) {
            self = .array(a)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unknown JSON type"
            )
        }
    }
}
