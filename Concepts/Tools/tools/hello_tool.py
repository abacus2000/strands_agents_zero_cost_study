from strands import tool

@tool(name='hello_test') # the ability to have a tool name different than the function is unique to using the @tool decorator
def hello(name: str) -> str:
    """Say hello to a person by name."""
    return f"Hello, {name}!"