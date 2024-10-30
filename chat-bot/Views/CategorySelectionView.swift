import SwiftUI

struct CategorySelectionView: View {
    @EnvironmentObject private var viewModel: ChatViewModel

    var body: some View {
        List {
            Section {
                ForEach(Category.allCases) { category in
                    Button(action: {
                        viewModel.selectedCategory = category
                    }) {
                        Text(category.rawValue)
                            .foregroundColor(.primary)
                    }
                }
            } header: {
                Text("你有什么问题需要咨询:")
            }
        }
        .navigationTitle("AI咨询助手")
    }
}
