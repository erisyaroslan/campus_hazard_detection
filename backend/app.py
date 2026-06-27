import os

from datetime import datetime
from flask import Flask
from flask import request
from flask import jsonify
from model_runner import run_all_models
from harmonizer import (harmonize_predictions, get_category)
from feature_builder import (build_features)
from meta_classifier import (classify)
from llm import get_action
from logger import save_detection
from iou_matcher import match_boxes


app = Flask(__name__)

@app.route("/")
def home():

    return "Backend Running"

@app.route("/health")
def health():

    return jsonify({

        "status":
            "online"
    })

@app.route(
    "/predict",
    methods=["POST"]
)
def predict():

    image = request.files["image"]
    zone = request.form["zone"]
    filename = datetime.now().strftime(
        "%Y%m%d_%H%M%S"
    ) + ".jpg"

    image_path = os.path.join(
        "evidence",
        filename
    )

    image.save(
        image_path
    )

    predictions = run_all_models(
        image_path
    )

    if len(predictions) == 0:

        return jsonify({
            "hazard": "No Hazard Detected",
            "category": "None",
            "confidence": 0,
            "severity": "None",
            "zone": zone,
            "action": "No campus hazard detected in the image."
    })

    predictions = harmonize_predictions(
        predictions
    )

    features = build_features(
        predictions,
        zone
    )
    print(features)

    result = classify(
        predictions,
        features
    )

    category = get_category(
        result["hazard"]
    )

    action = get_action(

        result["hazard"],

        category,

        result["zone"],

        result["severity"]
    )

    save_detection({

        "hazard":
            result["hazard"],

        "severity":
            result["severity"],

        "zone":
            result["zone"],

        "confidence":
            result["confidence"],

        "image":
            filename
    })

    return jsonify({

        "hazard":
            result["hazard"],

        "category":
            category,

        "confidence":
            result["confidence"],

        "severity":
            result["severity"],

        "zone":
            result["zone"],

        "action":
            action,

        "image":
            filename
    })

if __name__ == "__main__":

    app.run(
        host="0.0.0.0",
        port=5000,
        debug=True
    )