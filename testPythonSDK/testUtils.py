import os
import pickle
from typing import List, Dict
import tiktoken

def num_tokens_from_messages(messages, model="gpt-4o-mini"):
    """Return the number of tokens used by a list of messages."""
    try:
        encoding = tiktoken.encoding_for_model(model)
    except KeyError:
        print("Warning: model not found. Using o200k_base encoding.")
        encoding = tiktoken.get_encoding("o200k_base")
    if model in {
        "gpt-3.5-turbo-0125",
        "gpt-4-0314",
        "gpt-4-32k-0314",
        "gpt-4-0613",
        "gpt-4-32k-0613",
        "gpt-4o-mini-2024-07-18",
        "gpt-4o-2024-08-06"
        }:
        tokens_per_message = 3 # Specific to Chat API
        tokens_per_name = 1 # Extra token if name field is present
    elif "gpt-3.5-turbo" in model:
        print("Warning: gpt-3.5-turbo may update over time. Returning num tokens assuming gpt-3.5-turbo-0125.")
        return num_tokens_from_messages(messages, model="gpt-3.5-turbo-0125")
    elif "gpt-4o-mini" in model:
        print("Warning: gpt-4o-mini may update over time. Returning num tokens assuming gpt-4o-mini-2024-07-18.")
        return num_tokens_from_messages(messages, model="gpt-4o-mini-2024-07-18")
    elif "gpt-4o" in model:
        print("Warning: gpt-4o and gpt-4o-mini may update over time. Returning num tokens assuming gpt-4o-2024-08-06.")
        return num_tokens_from_messages(messages, model="gpt-4o-2024-08-06")
    elif "gpt-4" in model:
        print("Warning: gpt-4 may update over time. Returning num tokens assuming gpt-4-0613.")
        return num_tokens_from_messages(messages, model="gpt-4-0613")
    else:
        raise NotImplementedError(
            f"""num_tokens_from_messages() is not implemented for model {model}."""
        )
    num_tokens = 0
    for message in messages:
        num_tokens += tokens_per_message
        for key, value in message.items():
            num_tokens += len(encoding.encode(value))
            if key == "name":
                num_tokens += tokens_per_name
    num_tokens += 3  # every reply is primed with <|start|>assistant<|message|>
    return num_tokens

# Function to calculate tokens in messages
def save_pickle(obj, filename):
    with open(filename, 'wb') as f:
        pickle.dump(obj, f)
def load_pickle(filename):
    with open(filename, 'rb') as f:
        return pickle.load(f)
def print_properties(obj, indent=0):
    # Generate indentation for nested properties
    prefix = ' ' * indent

    # If the object is a dictionary, recursively print each key and value
    if isinstance(obj, dict):
        for key, value in obj.items():
            print(f"{prefix}{key}:")
            print_properties(value, indent + 2)

    # If the object is a list, recursively print each item
    elif isinstance(obj, list):
        for index, item in enumerate(obj):
            print(f"{prefix}[{index}]:")
            print_properties(item, indent + 2)

    # If the object has attributes (e.g., an OpenAI object), list them
    elif hasattr(obj, '__dict__'):
        for key, value in obj.__dict__.items():
            print(f"{prefix}{key}:")
            print_properties(value, indent + 2)

    # Base case: print the value if it's a simple data type
    else:
        print(f"{prefix}{obj}")
