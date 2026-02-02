from typing import Any


# when tool spec is used and 'tool' is passed to the func parameter, we don't need to tool decorator. 
# using this method, the tool spec must match the function name, when the @tool decorator is not used 

TOOL_SPEC = {
    "name": "weather_module",
    "description": "Get weather forecast for a city.",
    "inputSchema": {
        "json": {
            "type": "object",
            "properties": {
                "city": {
                    "type": "string",
                    "description": "The name of the city"
                },
                "days": {
                    "type": "integer",
                    "description": "Number of days for the forecast",
                    "default": 3
                }
            },
            "required": ["city"]
        }
    }
}

def weather_module(tool, **kwargs: Any):

    # extract params
    tool_use_id = tool["toolUseId"]
    tool_input = tool["input"]

    # get tool inputs from parameter values
    city = tool_input.get("city", "")
    days = tool_input.get("days", 3)

    result = f"Weather forecast for {city} for the next {days} days..."

    return {
        "toolUseId": tool_use_id,
        "status": "success",
        "content": [{"text": result}]
    }