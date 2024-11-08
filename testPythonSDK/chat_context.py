from openai import OpenAI
from dotenv import load_dotenv
load_dotenv()
client = OpenAI()

# Initialize the conversation history with a system message
conversation_history = [
    {"role": "system", "content": "You are a helpful assistant. Respond concisely and politely."}
]

def add_message(role, content):
    """Adds a new message to the conversation history."""
    conversation_history.append({"role": role, "content": content})

def chat_with_assistant(user_message):
    """Adds user input to history, calls the OpenAI API, and adds the assistant's response to history."""
    
    # Append the user's message to the conversation history
    add_message("user", user_message)
    
    # Make API call with current conversation history
    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=conversation_history,
    )
    
    # Extract the assistant's response from the API response
    assistant_reply    = response.choices[0].message.content
    
    # Append the assistant's response to the conversation history
    add_message("assistant", assistant_reply)
    
    return assistant_reply

def main():
    print("Welcome to the Chatbot! Type 'exit' to end the conversation.\n")

    while True:
        # Get user input
        user_message = input("You: ")
        
        # Exit if user types 'exit'
        if user_message.lower() == "exit":
            print("Goodbye!")
            break

        # Get assistant's response
        assistant_reply = chat_with_assistant(user_message)
        
        # Print assistant's response
        print("Assistant:", assistant_reply)

if __name__ == "__main__":
    main()
