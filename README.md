Hello World Application
=======================

This is a simple "Hello World" application that exposes two HTTP-based APIs:

* `PUT /hello/<username>`: Saves or updates the given user's name and date of birth in the database.
* `GET /hello/<username>`: Returns a hello message for the given user, including their birthday message if it's today or in the next N days.

Requirements
------------

* Python 3.8+
* Flask 2.0+
* SQLite3
* AWS account for deployment

Usage
-----

### Local Development

1. Install dependencies: `pip install flask sqlite3`
2. Run the application: `python app.py`
3. Run test: `python -m unittest tests/test_app.py`
3. Test the APIs using `curl` or a tool like Postman

