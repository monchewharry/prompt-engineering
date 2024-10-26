// to improve the structure, maintainability, and user experience
// 1.	Separate API Logic: Move the API request logic to a separate manager class.
// 2.	Improve State Management: Consider using a ViewModel for better state management.
// 3.	Refine User Interface: Enhance user feedback and response handling for a smoother experience.
// 4.	Handle Loading States and Errors: Display a loading indicator while waiting for the API response and handle errors gracefully.

import SwiftUI
import OpenAI

// OpenAI Manager to handle API calls
// a separate class for the OpenAI API logic, improving code separation and maintainability.
class OpenAIManager: ObservableObject {
    private let apiKey: String? = ProcessInfo.processInfo.environment["OPENAI_API_KEY"]
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    func sendRequest(systemMessage: String, assistantMessage: String, userMessage: String, completionHandler: @escaping (String) -> Void) {
        guard let apiKey = apiKey else {
            errorMessage = "API key not found."
            completionHandler("Error: API key is not found in the environment.")
            return
        }

        let messages: [ChatQuery.ChatCompletionMessageParam] = [
            .init(role: .system, content: systemMessage)!,
            .init(role: .assistant, content: assistantMessage)!,
            .init(role: .user, content: userMessage)!
        ]

        let query = ChatQuery(messages: messages, model: .gpt4_o_mini)
        isLoading = true

        Task {
            do {
                let configuration = OpenAI.Configuration(token: apiKey)
                let openAI = OpenAI(configuration: configuration)
                let completion: ChatResult = try await openAI.chats(query: query)

                // Extract and return the response content
                if let content = completion.choices.first?.message.content?.string {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        completionHandler(content)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        completionHandler("No response content found")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    completionHandler("Error: \(error.localizedDescription)")
                }
            }
        }
    }
}

// View Model
// The ViewModel will handle data preparation and logic, improving separation of concerns.
class ZiweiViewModel: ObservableObject {
    @ObservedObject var p1: PeopleApp
    @Published var response: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    @Published private(set) var SystemQueryString: String = ""
    @Published private(set) var AssistantString: String = ""
    @Published private(set) var UserQueryString: String = ""

    private var openAIManager = OpenAIManager()

    init(p1: PeopleApp) {
        self.p1 = p1
    }

    // Prepare all messages
    func setupPromptMessages(test: Bool = false) {
        let fullMessage = getFullMessage()
        generateSystemMessage(palaceDes: fullMessage.palaceDes)
        generateAssistantMessage()
        UserQueryString = "\"\"\"\n\(fullMessage.mainMessage)\"\"\""

        if test {
            print("SystemQueryString:\n\(SystemQueryString)\nAssistantString:\n\(AssistantString)\nUserQueryString:\n\(UserQueryString)")
        }
    }

    func sendRequest() {
        isLoading = true
        openAIManager.sendRequest(systemMessage: SystemQueryString, assistantMessage: AssistantString, userMessage: UserQueryString) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                self.response = result
            }
        }
    }

    // Generate the System and Assistant messages
    private func generateSystemMessage(palaceDes: String) {
        SystemQueryString = """
        你是一个熟悉中国紫微斗数理论的算命先生。请按照以下步骤提供总结:
        1. ... (Your system message content)
        """
    }

    private func generateAssistantMessage() {
        AssistantString = """
        ### 星盘总结
        模型在这里总结我的星盘格局
        ### 星盘详解
        模型在这里给出上述总结的详细依据
        ### 修身意见
        模型在这里给出针对我的星盘格局中负面的情况的意见。
        """
    }

    private func getFullMessage() -> (palaceDes: String, mainMessage: String, sihuaMessage: String) {
        let generator = ziweiMessage(the12Palaces: p1.twelvePalaceCubes)
        return generator.fullMessage
    }
}

// arrange the ziwei natal chart information
struct ziweiMessage {
    let the12Palaces: [ZiweiPalaceCube]
    var fullMessage: (palaceDes:String,mainMessage:String,sihuaMessage:String) {
        getFullMessage()
    }
    /// prepare information for all 12 palaces
    private func getFullMessage() -> (String, String, String) {
        var palaceDes: String = ""
        var message: String = ""
        var sihuaNote: String = ""
        var sihuaAppendix:String=""

        for (index, palace) in the12Palaces.enumerated() {
            let (palaceDesMessage, mainMessage, sihuaMessage) = messagePerPalace(palace: palace)
            palaceDes += "\(index+1)." + palaceDesMessage
            message += "\(index+1)." + mainMessage
            sihuaNote += sihuaMessage
        }
        let sihuaAppendixLines = sihuaNote.components(separatedBy: .newlines)

        for line in sihuaAppendixLines {

            let cleanedline = line.trimmingCharacters(in: .whitespacesAndNewlines)
            let sihuaname = String(cleanedline.suffix(1))
            if let sihuaenum = sihuaEnum(rawValue: sihuaname){
                sihuaAppendix += "\n化\(sihuaname):\n \(ziweiKnowledge.sihuaStarDes?[sihuaenum] ?? "")\n"
            }
        }

        return (palaceDes, message, sihuaNote ) //+ "\n四化附录\n" + sihuaNote + sihuaAppendix
    }

    /// prepare information for each palace
    private func messagePerPalace(palace: ZiweiPalaceCube) -> (assistantMessage:String,mainMessage:String,sihuaMessage:String) {
        let palaceDesString = ziweiKnowledge.palaceDes[palace.palaceNameEnum]!
        var palaceDesMessage: String = ""
        var mainMessage: String = "\(palace.palaceName):"
        var sihuaMessage: String = ""
        palaceDesMessage += "\(palace.palaceName): \(palaceDesString)\n"

        let interpreter = setupInterpreter(palace: palace)
        var interpreterResult = ""
        for star in palace.allStars {
            // record sihua situation
            if let starSihua = star.sihua {
                sihuaMessage += "\(palace.palaceName):\(star.name)化\(starSihua.rawValue)\n"
            }

            let result = interpreter.interpret(star: star, in: palace)
            for (title, content) in result.sorted(by: { $0.key < $1.key }) {
                if title.contains("化"){
                    //interpreterResult += "包含四化：\(title)，依据最后的四化附录调整解读。\n"
                } else {
                    interpreterResult += "\(content)\n"
                }
            }
        }
        interpreterResult += "\n"// seperate palaces

        mainMessage += interpreterResult
        return (palaceDesMessage, mainMessage,sihuaMessage)
    }

    private func setupInterpreter(palace: ZiweiPalaceCube) -> StarInterpreter {
        var interpreter = StarInterpreter()
        for star in palace.allStars {
            interpreter.registerRule(for: star.pinyin,in: palace,
                                     rule: starRuleMappings(star.pinyin))
        }
        return interpreter
    }
}


struct OpenAI_ZiweiView: View {
    @ObservedObject private var viewModel: ZiweiViewModel

    // Initialize with PeopleApp instance
    init(p1: PeopleApp) {
        // Construct the ViewModel using p1
        self._viewModel = ObservedObject(wrappedValue: ZiweiViewModel(p1: p1))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                pageHeader

                if viewModel.isLoading {
                    ProgressView("Generating response...")
                } else {
                    Markdown(viewModel.response)
                }

                if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                }

                Divider()
            }
            .padding()
        }
    }

    // MARK: - Subviews
    private var pageHeader: some View {
        VStack {
            Text("AI Chat")
                .font(.largeTitle)
                .padding()

            Text("紫微斗数命盘AI分析")
                .padding()

            Button(action: {
                viewModel.setupPromptMessages()
                viewModel.sendRequest()
            }) {
                Text("Get Answer")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }
}
