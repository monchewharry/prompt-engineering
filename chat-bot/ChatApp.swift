import SwiftUI

@main
struct ChatApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ChatViewModel())
        }
    }
}
