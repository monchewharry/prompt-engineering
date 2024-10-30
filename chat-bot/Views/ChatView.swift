import SwiftUI

struct ChatView: View {
    @EnvironmentObject private var viewModel: ChatViewModel

    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        MessageBubble(message: message)
                    }

                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                TextField("输入问题...", text: $viewModel.currentInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: {
                    Task {
                        await viewModel.sendMessage()
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                }
                .disabled(
                    viewModel.currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
        .navigationTitle(viewModel.selectedCategory?.rawValue ?? "")
        .navigationBarItems(
            leading: Button("返回") {
                viewModel.clearChat()
            }
        )
    }
}
