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