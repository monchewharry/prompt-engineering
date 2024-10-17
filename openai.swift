//
//  openai.swift
//  shensuan
//
//  Created by Dingxian Cao on 10/17/24.
//

import SwiftUI
#Preview {
    openai()
}

struct openai: View {
    @State private var response: String = ""

    var body: some View {
        ScrollView{
            VStack(spacing: 16) {
                Text("AI Chat")
                    .font(.largeTitle)
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

            }.padding()
        }
        
    }
    
    // Function to send the API request
    func sendRequest(completion: @escaping (String) -> Void) {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? "")", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": "You are a helpful assistant."],
                ["role": "user", "content": "Which city is China's capital?"]
            ]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = jsonResponse["choices"] as? [[String: Any]],
               let message = choices.first?["message"] as? [String: Any],
               let content = message["content"] as? String {
                completion(content)
            } else {
                completion("Failed to parse response")
            }
        }.resume()
    }
}

