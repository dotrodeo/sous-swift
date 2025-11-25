import Foundation
import SwiftUI

struct HighlightedSegment: Identifiable {
    let id = UUID()
    var text: String
    var isHighlighted: Bool
    var match: FuzzyMatchResult<IngredientKeyword>?
}

struct IngredientKeyword {
    let keyword: String
    let fullIngredient: String
}

struct InstructionHighlighter {

    private let STOPWORDS: Set<String> = [
        "a", "an", "and", "or", "but", "the", "in", "on", "at", "to", "for",
        "with", "from", "of", "by", "as",
        "is", "was", "are", "be", "been", "into", "over", "until", "add",
        "heat", "cook", "stir", "mix",
        "chop", "dice", "slice", "pour", "place", "put", "set", "let", "low",
        "medium", "high", "large",
        "small", "more", "less", "cup", "cups", "tablespoon", "tablespoons",
        "teaspoon", "teaspoons",
        "tsp", "tbsp", "oz", "ounce", "ounces", "pound", "pounds", "gram",
        "grams", "liter", "liters",
        "ml", "lb", "lbs", "pinches", "pinch", "dash", "finish", "serve",
        "proof", "melt", "divide",
        "season", "needed", "spoon",
    ]

    func highlight(
        ingredients: [String],
        instruction: String,
        threshold: Double = 0.4
    ) -> [HighlightedSegment] {

        // MARK: Extract ingredient keyword objects
        func extractIngredientKeywordsWithRefs(_ ingredients: [String])
            -> [IngredientKeyword]
        {
            var seen = Set<String>()
            var list: [IngredientKeyword] = []

            for full in ingredients {
                let cleaned = full.lowercased()
                    .replacingOccurrences(
                        of: "[^a-z0-9\\s]",
                        with: " ",
                        options: .regularExpression
                    )
                let tokens =
                    cleaned
                    .split(whereSeparator: { $0.isWhitespace })
                    .map(String.init)
                    .filter { $0.count > 2 && !STOPWORDS.contains($0) }

                for token in tokens {
                    let key = "\(token)|\(full)"
                    if !seen.contains(key) {
                        seen.insert(key)
                        list.append(
                            IngredientKeyword(
                                keyword: token,
                                fullIngredient: full
                            )
                        )
                    }
                }
            }

            return list
        }

        let keywordMap = extractIngredientKeywordsWithRefs(ingredients)

        // MARK: Fuzzy search instance
        let fuse = FuzzySearch(items: keywordMap, keyPath: \.keyword)

        // MARK: Tokenize instruction (keep punctuation + whitespace)
        let regex = try! NSRegularExpression(
            pattern: "\\b[\\w'-]+\\b|[^\\w\\s]+|\\s+"
        )
        let nsInstruction = instruction as NSString
        let matches = regex.matches(
            in: instruction,
            range: NSRange(location: 0, length: nsInstruction.length)
        )

        let tokens = matches.map { nsInstruction.substring(with: $0.range) }

        var result: [HighlightedSegment] = []
        let MAX_PHRASE_LEN = 4
        var i = 0

        while i < tokens.count {
            let token = tokens[i]

            // Skip whitespace or punctuation
            if token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                || token.range(of: "^[^\\w'-]+$", options: .regularExpression)
                    != nil
            {

                result.append(
                    HighlightedSegment(text: token, isHighlighted: false)
                )
                i += 1
                continue
            }

            var bestMatch: FuzzyMatchResult<IngredientKeyword>? = nil
            var bestLen = 0

            // MARK: Try multi-word phrases
            for len in stride(from: MAX_PHRASE_LEN, to: 0, by: -1) {
                let phraseTokens = tokens[i..<min(i + len, tokens.count)]
                    .filter {
                        $0.range(of: "^[\\w'-]+$", options: .regularExpression)
                            != nil
                    }

                if phraseTokens.isEmpty { continue }

                let phrase = phraseTokens.joined(separator: " ").lowercased()

                // Skip single stopwords
                if len == 1, STOPWORDS.contains(phrase) { continue }

                let searchResults = fuse.search(phrase, maxScore: threshold)
                guard let top = searchResults.first else { continue }

                let keyword = top.item.keyword

                // Boundary check
                if phrase.range(
                    of: "\\b\(keyword)\\b",
                    options: [.regularExpression, .caseInsensitive]
                ) == nil {
                    continue
                }

                // Skip phrases starting/ending with stopwords
                let words = phrase.split(separator: " ")
                if let first = words.first, STOPWORDS.contains(String(first)) {
                    continue
                }
                if let last = words.last, STOPWORDS.contains(String(last)) {
                    continue
                }

                bestMatch = top
                bestLen = len
            }

            if let match = bestMatch {
                let matchedText = tokens[i..<i + bestLen].joined()
                result.append(
                    HighlightedSegment(
                        text: matchedText,
                        isHighlighted: true,
                        match: match
                    )
                )
                i += bestLen
            } else {
                result.append(
                    HighlightedSegment(text: token, isHighlighted: false)
                )
                i += 1
            }
        }

        var merged: [HighlightedSegment] = []
        for seg in result {
            if let last = merged.last, last.isHighlighted == seg.isHighlighted {
                merged[merged.count - 1].text += seg.text
            } else {
                merged.append(seg)
            }
        }

        return merged
    }

}

extension Array where Element == HighlightedSegment {
    func asAttributedString() -> AttributedString {
        var result = AttributedString()

        for segment in self {
            var attr = AttributedString(segment.text)

            if segment.isHighlighted {
                // style
                attr.foregroundColor = .blue
                attr.underlineStyle = .single

                // set a link which we will intercept with .onOpenURL
                if let url = URL(string: "highlight://\(segment.id.uuidString)") {
                    attr.link = url
                }
            }

            result += attr
        }

        return result
    }
}
