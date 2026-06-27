import requests
import os
from dotenv import load_dotenv

load_dotenv()

MODEL_A_URL = ("https://detect.roboflow.com/electrical-facilities-hazards/6")
MODEL_A_KEY = os.getenv("MODEL_A_KEY")

MODEL_B_URL = ("https://detect.roboflow.com/campus-hazard-detection-togw1/3")
MODEL_B_KEY = os.getenv("MODEL_B_KEY")

MODEL_C_URL = ("https://detect.roboflow.com/campus-hazard-detection-cnhg6/5")
MODEL_C_KEY = os.getenv("MODEL_C_KEY")

def run_model(model_url, api_key, image_path):

    with open(image_path, "rb") as image:

        response = requests.post(
            model_url,
            params={
                "api_key": api_key
            },
            files={
                "file": image
            }
        )

    return response.json()


def run_model_a(image_path):
    return run_model(
        MODEL_A_URL,
        MODEL_A_KEY,
        image_path
    )


def run_model_b(image_path):
    return run_model(
        MODEL_B_URL,
        MODEL_B_KEY,
        image_path
    )


def run_model_c(image_path):
    return run_model(
        MODEL_C_URL,
        MODEL_C_KEY,
        image_path
    )

def extract_predictions(result, model_name):

    predictions = []

    for p in result.get("predictions", []):

        predictions.append({

            "model": model_name,

            "class": p["class"],

            "confidence": p["confidence"],

            "bbox": [

                p["x"],
                p["y"],
                p["width"],
                p["height"]
            ]
        })

    return predictions


def run_all_models(image_path):

    all_predictions = []

    result_a = run_model_a(image_path)

    result_b = run_model_b(image_path)

    result_c = run_model_c(image_path)

    all_predictions += extract_predictions(
        result_a,
        "A"
    )

    all_predictions += extract_predictions(
        result_b,
        "B"
    )

    all_predictions += extract_predictions(
        result_c,
        "C"
    )

    return all_predictions