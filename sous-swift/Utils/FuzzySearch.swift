import Foundation

struct FuzzyMatchResult<T> {
    let item: T
    let score: Double
}

class FuzzySearch<T, V: StringProtocol> {
    private let items: [T]
    private let keyPath: KeyPath<T, V>
    
    init(items: [T], keyPath: KeyPath<T, V>) {
        self.items = items
        self.keyPath = keyPath
    }
    
    private func normalize(_ string: String) -> String {
        string.lowercased()
              .folding(options: .diacriticInsensitive, locale: .current)
    }
    
    private func levenshtein(_ a: String, _ b: String) -> Int {
        let aChars = Array(a)
        let bChars = Array(b)
        let m = aChars.count
        let n = bChars.count
        var dp = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)
        for i in 0...m { dp[i][0] = i }
        for j in 0...n { dp[0][j] = j }
        for i in 1...m {
            for j in 1...n {
                if aChars[i-1] == bChars[j-1] {
                    dp[i][j] = dp[i-1][j-1]
                } else {
                    dp[i][j] = min(
                        dp[i-1][j] + 1,
                        dp[i][j-1] + 1,
                        dp[i-1][j-1] + 1
                    )
                }
            }
        }
        return dp[m][n]
    }
    
    func search(_ query: String, maxScore: Double = 0.6) -> [FuzzyMatchResult<T>] {
        let normQuery = normalize(query)
        var results: [FuzzyMatchResult<T>] = []
        
        for item in items {
            let value = normalize(String(item[keyPath: keyPath]))
            let distance = levenshtein(normQuery, value)
            let maxLen = max(normQuery.count, value.count)
            let score = maxLen == 0 ? 0 : Double(distance) / Double(maxLen)
            
            if score <= maxScore {
                results.append(FuzzyMatchResult(item: item, score: score))
            }
        }
        
        return results.sorted { $0.score < $1.score }
    }
}
