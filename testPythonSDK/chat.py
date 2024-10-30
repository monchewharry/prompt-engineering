from dotenv import load_dotenv
from openai import OpenAI
import os
from enum import Enum

# Load environment variables
load_dotenv()

client = OpenAI()

class Category(Enum):
    RELATIONSHIP = "情感"
    WORK = "工作"
    DESTINY = "运势"

def get_user_category_choice() -> Category:
    while True:
        categories = list(Category)
        print("\n你有什么问题需要咨询:")
        for i, category in enumerate(categories, start=1):
            print(f"{i}. {category.value}")
        
        try:
            choice = int(input("请回复问题类型的数字 (或输入 'q' 退出): "))
            if choice in range(1, len(categories) + 1):
                return categories[choice - 1]
            else:
                print("请输入有效的数字选项。")
        except ValueError:
            print("请输入有效的数字。")

def get_user_question(selected_category: Category) -> str:
    while True:
        question = input(f"\n关于{selected_category.value}，你想问什么问题? (或输入 'q' 返回): ").strip()
        if question and question.lower() != 'q':
            return question
        elif question.lower() == 'q':
            return None
        print("请输入有效的问题。")

def fetch_openai_response(category: Category, user_question: str) -> str:
    try:
        system_prompts = {
            Category.RELATIONSHIP: "你是一位经验丰富的情感顾问，专注于帮助人们解决感情、人际关系等问题。请以温暖、理解的态度提供建议。",
            Category.WORK: "你是一位职业发展顾问，擅长解答关于职业规划、工作环境、职场关系等问题。请提供专业、实用的建议。",
            Category.DESTINY: "你是一位运势分析师，善于解读人生方向、机遇挑战等问题。请给出积极正面但实事求是的建议。"
        }

        response = client.chat.completions.create(
            model="gpt-3.5-turbo",  # or "gpt-4" if you have access
            messages=[
                {"role": "system", "content": system_prompts[category]},
                {"role": "user", "content": user_question}
            ],
            temperature=0.7,
            max_tokens=500
        )
        
        # Get token usage information
        completion_tokens = response.usage.completion_tokens
        prompt_tokens = response.usage.prompt_tokens
        total_tokens = response.usage.total_tokens
        
        answer = response.choices[0].message.content
        return f"{answer}\n\n[Token Usage: Completion={completion_tokens}, Prompt={prompt_tokens}, Total={total_tokens}]"
    except Exception as e:
        return f"抱歉，获取回答时出现错误: {str(e)}"

def chat_with_user() -> None:
    print("欢迎使用AI咨询助手！")
    
    while True:
        selected_category = get_user_category_choice()
        if not selected_category:
            continue

        while True:
            user_question = get_user_question(selected_category)
            if not user_question:
                break

            print("\n正在思考...")
            answer = fetch_openai_response(selected_category, user_question)
            print(f"\n回答: {answer}\n")
            
            continue_chat = input("是否继续在当前类别提问？(y/n): ").lower()
            if continue_chat != 'y':
                break

        continue_program = input("\n是否想咨询其他类别？(y/n): ").lower()
        if continue_program != 'y':
            print("感谢使用AI咨询助手！再见！")
            break

if __name__ == "__main__":
    chat_with_user()