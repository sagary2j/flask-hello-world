# Set base image (host OS)
FROM python:3.12-alpine

WORKDIR /app

# Copy the dependencies file to the working directory
COPY requirements.txt .

# To install required packages
RUN apk update && apk add curl

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# By default, listen on port 5000 but we are adding custom one
EXPOSE 8000/tcp

# Specify the command to run on container start
CMD [ "python", "app.py" ]
