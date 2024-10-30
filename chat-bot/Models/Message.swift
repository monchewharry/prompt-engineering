import Foundation

struct Message: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let tokenInfo: TokenInfo?
}

struct TokenInfo {
    let completion: Int
    let prompt: Int
    let total: Int
}
