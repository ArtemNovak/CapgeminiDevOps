import azure.functions as func
import json

app = func.FunctionApp(http_auth_level=func.AuthLevel.FUNCTION)

@app.route(route="greeting/{name?}", methods=["GET"])
def GetGreeting(req: func.HttpRequest) -> func.HttpResponse:
    # The name is part of the URL path and is optional
    name = req.route_params.get('name', None)

    if name:
        return func.HttpResponse(
            json.dumps({
                'message': f"Hello, {name}! Welcome to Azure Functions."
            }),
            mimetype="application/json"
        )
    else:
        return func.HttpResponse(
            json.dumps({
                'message': "Hello! Please provide your name."
            }),
            mimetype="application/json",
            status_code=200
        )

@app.route(route="greeting", methods=["POST"])
def PostGreeting(req: func.HttpRequest) -> func.HttpResponse:
    try:
        # Get name from the request body
        req_body = req.get_json()
        name = req_body.get('name')
        
        if name:
            return func.HttpResponse(
                json.dumps({
                    'message': f"Hello, {name}! Welcome to Azure Functions."
                }),
                mimetype="application/json"
            )
        else:
            return func.HttpResponse(
                json.dumps({
                    'message': "Hello! Please provide your name."
                }),
                mimetype="application/json"
            )
    except ValueError:
        return func.HttpResponse(
            json.dumps({
                'message': "Hello! Please provide your name."
            }),
            mimetype="application/json"
        )