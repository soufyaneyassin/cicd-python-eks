from flask import Flask, jsonify

def create_app():
    app = Flask(__name__)

    @app.route("/health")
    def health():
        return jsonify(status="ok")
    
    @app.route("/hello/<name>")
    def hello(name):
        return jsonify(message=f"Hello {name}")
    
    return app