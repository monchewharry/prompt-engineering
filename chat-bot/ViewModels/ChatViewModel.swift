import Foundation

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var currentInput: String = ""
    @Published var selectedCategory: Category?
    @Published var isLoading = false

    private let openAIService = OpenAIService()

    func sendMessage() async {
        guard !currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            let category = selectedCategory
        else { return }

        let userMessage = Message(content: currentInput, isUser: true, tokenInfo: nil)
        messages.append(userMessage)

        isLoading = true
        currentInput = ""

        do {
            let (response, tokenInfo) = try await openAIService.fetchResponse(
                for: userMessage.content,
                category: category
            )

            let assistantMessage = Message(content: response, isUser: false, tokenInfo: tokenInfo)
            messages.append(assistantMessage)
        } catch {
            let errorMessage = Message(
                content: "抱歉，获取回答时出现错误: \(error.localizedDescription)",
                isUser: false,
                tokenInfo: nil
            )
            messages.append(errorMessage)
        }

        isLoading = false
    }

    func clearChat() {
        messages.removeAll()
        selectedCategory = nil
    }
}
