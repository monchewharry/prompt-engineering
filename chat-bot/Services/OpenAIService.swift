import Foundation

class OpenAIService {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"

    init() {
        // In a real app, you should load this from a secure location
        self.apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
    }

    func fetchResponse(for question: String, category: Category) async throws -> (String, TokenInfo)
    {
        let messages: [[String: String]] = [
            ["role": "system", "content": category.systemPrompt],
            ["role": "user", "content": question],
        ]

        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messages,
            "temperature": 0.7,
            "max_tokens": 500,
        ]

        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)

        let tokenInfo = TokenInfo(
            completion: response.usage.completion_tokens,
            prompt: response.usage.prompt_tokens,
            total: response.usage.total_tokens
        )

        return (response.choices[0].message.content, tokenInfo)
    }
}

// Response models for JSON decoding
struct OpenAIResponse: Codable {
    let choices: [Choice]
    let usage: Usage
}

struct Choice: Codable {
    let message: ChatMessage
}

struct ChatMessage: Codable {
    let content: String
}

struct Usage: Codable {
    let prompt_tokens: Int
    let completion_tokens: Int
    let total_tokens: Int
}
