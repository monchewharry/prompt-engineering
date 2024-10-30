import Foundation

enum Category: String, CaseIterable, Identifiable {
    case relationship = "情感"
    case work = "工作"
    case destiny = "运势"

    var id: String { self.rawValue }

    var systemPrompt: String {
        switch self {
        case .relationship:
            return "你是一位经验丰富的情感顾问，专注于帮助人们解决感情、人际关系等问题。请以温暖、理解的态度提供建议。"
        case .work:
            return "你是一位职业发展顾问，擅长解答关于职业规划、工作环境、职场关系等问题。请提供专业、实用的建议。"
        case .destiny:
            return "你是一位运势分析师，善于解读人生方向、机遇挑战等问题。请给出积极正面但实事求是的建议。"
        }
    }
}
