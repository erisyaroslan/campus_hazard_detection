import numpy as np
import pickle

from tensorflow.keras.models import load_model

model = load_model("meta_classifier.keras")

with open("label_encoder.pkl", "rb") as f:
    encoder = pickle.load(f)

SEVERITY_RULES = {

    "Exposed Live Wire": "High",
    "Dangling Wire": "High",
    "Broken Socket": "High",
    "Damaged Electrical Box": "High",

    "Uncovered Manhole": "High",
    "Open Drain": "High",

    "Pothole": "Medium",
    "Sunk Road": "Medium",

    "Broken Fence": "Medium",
    "Missing Barricade": "Medium",

    "Sharp Object": "Medium",

    "Crack Pavement": "Low",

    "Open Restricted Area": "Medium"
}


def classify(predictions, features):

    if len(predictions) == 0:

        return {

            "hazard":"No Hazard Detected",

            "confidence":0,

            "severity":"None",

            "zone": features[2],

            "boxes":None
        }

    feature_vector = np.array(features).reshape(1, -1)

    prediction = model.predict(feature_vector, verbose=0)

    predicted_index = np.argmax(prediction)

    predicted_label = encoder.inverse_transform([predicted_index])[0]

    predicted_confidence = float(np.max(prediction))

    print("\n========== NEURAL NETWORK META CLASSIFIER ==========")
    print("Input Features:")
    print(feature_vector)

    print("\nPrediction Probabilities:")
    print(prediction)

    print("\nPredicted Class:")
    print(predicted_label)

    print("Predicted Confidence:")
    print(predicted_confidence)

    print("===================================================\n")

    highest_yolo = max(predictions, key=lambda p: p["confidence"])

    print("Highest YOLO Prediction:")
    print(highest_yolo["class"])
    print(highest_yolo["confidence"])

    all_hazards = []

    for p in predictions:
             all_hazards.append({
                "hazard": p["class"],
                "confidence": round(p["confidence"], 3),
                "severity": SEVERITY_RULES.get(
                     p["class"],
                        "Medium"
                )
    })

    return {

    "hazard": predicted_label,

    "confidence": round(predicted_confidence,3),

    "severity": SEVERITY_RULES.get(predicted_label, "Medium"),

    "zone": "",

    "boxes": predictions,

    "hazards": all_hazards
}