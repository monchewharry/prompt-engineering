//
//  openai.swift
//
//  Created by Dingxian Cao on 10/17/24.
//
import SwiftUI
// https://github.com/MacPaw/OpenAI.git
import OpenAI

#Preview {
    OpenAIView()
}

struct OpenAIView: View {
    @State private var response: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("AI Chat")
                    .font(.largeTitle)
                    .padding()
                
                Text("Question: Which city is China's Capital?")
                    .padding()
                
                Button(action: {
                    sendRequest { result in
                        DispatchQueue.main.async {
                            response = result
                        }
                    }
                }) {
                    Text("Get Answer")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Text("Response:")
                    .font(.headline)
                    .padding(.top)
                
                Text(response)
                    .padding()
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
    }
    
    
    // Function to send the API request using OpenAIKit
    func sendRequest(completion: @escaping (String) -> Void) {
        // Construct the query
        let messages: [ChatQuery.ChatCompletionMessageParam] = [
            .init(role: .system , content: "You are a helpful assistant.")!,
            .init(role: .user, content: "Which city is China's capital?")!
            ]
        let query = ChatQuery(messages: messages,
                              model: .gpt4_o_mini)
        
        Task {
            do {
                // Create an instance of the OpenAI client
                guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
                    completion("Error: API key is not found in the environment.")
                    return
                }
                let configuration = OpenAI.Configuration(token: apiKey)
                let openAI = OpenAI(configuration: configuration)
                
                // Call the chat API
                let result:ChatResult = try await openAI.chats(query: query)
                
                // Extract the response content
                if let content = result.choices.first?.message.content?.string {
                    completion(content)
                } else {
                    completion("No response content found")
                }
            } catch {
                completion("Error: \(error.localizedDescription)")
            }
        }
    }
    
}


