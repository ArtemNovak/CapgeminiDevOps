import azure.functions as func
import json

def main(req: func.HttpRequest) -> func.HttpResponse:
    # Get the name parameter from query string or request body
    name = req.params.get('name')
    if not name:
        try:
            req_body = req.get_json()
            name = req_body.get('name')
        except ValueError:
            pass

    # Prepare the response based on whether name was provided
    if name:
        response_message = f"Hello, {name}! Welcome to Azure Functions."
    else:
        response_message = "Hello! Please provide your name."
    
    # Return the response with appropriate headers
    return func.HttpResponse(
        body=json.dumps({
            "message": response_message
        }),
        mimetype="application/json",
        status_code=200
    )