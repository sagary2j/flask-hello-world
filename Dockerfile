# Set base image (host OS)
FROM python:3.7.4

WORKDIR /app

# Copy the dependencies file to the working directory
COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# By default, listen on port 5000
EXPOSE 5000

# Specify the command to run on container start
CMD [ "python", "app.py" ]
