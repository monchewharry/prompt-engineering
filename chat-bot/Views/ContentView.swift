import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: ChatViewModel

    var body: some View {
        NavigationView {
            if viewModel.selectedCategory == nil {
                CategorySelectionView()
            } else {
                ChatView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ChatViewModel())
    }
}
