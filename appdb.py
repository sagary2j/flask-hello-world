import boto3
from flask import Flask, request, jsonify
from datetime import datetime, timedelta
import logging
from botocore.exceptions import ClientError

logging.basicConfig(level=logging.DEBUG)

app = Flask(__name__)

dynamodb = boto3.resource('dynamodb', region_name='us-east-1') 
table = dynamodb.Table('users')

@app.route("/hello/<username>", methods=["PUT"])
def save_user_data(username):
    data = request.get_json()
    date_of_birth = data["dateOfBirth"]
    
    if not username.isalpha():
        return jsonify({"error": "Username must contain only letters"}), 400
    try:
        datetime.strptime(date_of_birth, "%Y-%m-%d")
    except ValueError:
        return jsonify({"error": "Invalid date format. Use YYYY-MM-DD."}), 400

    if datetime.strptime(date_of_birth, "%Y-%m-%d") >= datetime.today():
        return jsonify({"error": "Date of birth must be in the past."}), 400
    
    try:
        table.put_item(Item={
            'username': username,
            'date_of_birth': date_of_birth
        })
        return "", 204
    except ClientError as e:
        logging.error(e.response['Error']['Message'])
        return jsonify({"error": "Internal server error"}), 500

@app.route("/hello/<username>", methods=["GET"])
def get_hello_message(username):
    try:
        response = table.get_item(Key={'username': username})
    except ClientError as e:
        logging.error(e.response['Error']['Message'])
        return jsonify({"error": "Internal server error"}), 500
    
    if 'Item' in response:
        date_of_birth = response['Item']['date_of_birth']
        today = datetime.today()
        
        # Calculate next birthday
        this_year_birthday = datetime(today.year, date_of_birth.month, date_of_birth.day)
        
        if today > this_year_birthday:
            next_year_birthday = datetime(today.year + 1, date_of_birth.month, date_of_birth.day)
            delta = next_year_birthday - today
        else:
            delta = this_year_birthday - today
        days_until_birthday = delta.days + 1
        if days_until_birthday == 365:
            message = f"Hello, {username}! Happy birthday!"
        else:
            message = f"Hello, {username}! Your birthday is in {days_until_birthday} day(s)"
    else:
        message = f"User {username} not found"
    return jsonify({"message": message}), 200

@app.route('/health', methods=['GET'])
def health_check():
    return "Healthy Application"

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=8000)