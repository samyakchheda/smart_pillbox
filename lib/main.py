import os
import base64
import json
from google.oauth2 import service_account
from google.auth.transport.requests import Request
from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

# Step 1: Get OAuth 2.0 Access Token
def get_access_token():
    # Get the base64-encoded credentials from environment variables
    credentials_base64 = os.getenv("FIREBASE_CREDENTIALS")
    if not credentials_base64:
        raise ValueError("Firebase credentials are not set in environment variables")

    # Decode the base64 string and load it as JSON
    credentials_json = base64.b64decode(credentials_base64).decode('utf-8')
    credentials_dict = json.loads(credentials_json)

    # Load the credentials from the decoded JSON
    credentials = service_account.Credentials.from_service_account_info(
        credentials_dict,
        scopes=['https://www.googleapis.com/auth/firebase.messaging']
    )

    # Ensure the token is fresh (this will refresh the token if expired)
    credentials.refresh(Request())

    # Return the valid access token
    return credentials.token

# Step 2: Send Notification
def send_notification(device_token, title, body, custom_data):
    access_token = get_access_token()  # Get the refreshed access token

    # Replace with your project ID
    project_id = 'final-year-project-6ebae'  # Replace with your Firebase project ID

    # FCM v1 API endpoint
    url = f'https://fcm.googleapis.com/v1/projects/{project_id}/messages:send'

    # Notification payload
    payload = {
        "message": {
            "token": device_token,
            "notification": {
                "title": title,
                "body": body
            },
            "data": custom_data
        }
    }

    # HTTP headers
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }

    # Send the POST request
    response = requests.post(url, headers=headers, json=payload)
    print(response.json())
    return response.json()

@app.route('/send_notification', methods=['POST'])
def send_notification_route():
    data = request.json
    device_token = data.get('token')
    title = data.get('title')
    body = data.get('body')
    custom_data = data.get('custom_data', {})

    try:
        # Trigger the notification sending process
        response = send_notification(device_token, title, body, custom_data)
        
        return jsonify({"status": "success", "response": response}), 200
    except Exception as e:
        # Handle any errors that occur during the notification process
        return jsonify({"status": "error", "message": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)
