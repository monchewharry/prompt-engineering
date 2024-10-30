import SwiftUI

struct MessageBubble: View {
    let message: Message

    var body: some View {
        VStack(alignment: message.isUser ? .trailing : .leading) {
            HStack {
                if message.isUser {
                    Spacer()
                }

                Text(message.content)
                    .padding()
                    .background(message.isUser ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundColor(message.isUser ? .white : .primary)
                    .cornerRadius(16)

                if !message.isUser {
                    Spacer()
                }
            }

            if let tokenInfo = message.tokenInfo {
                Text(
                    "Tokens: Completion=\(tokenInfo.completion), Prompt=\(tokenInfo.prompt), Total=\(tokenInfo.total)"
                )
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
    }
}
