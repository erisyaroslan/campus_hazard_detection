from collections import Counter


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

            "zone":features["zone"],

            "boxes":None
        }

    labels = [p["class"] for p in predictions]

    confidences = [p["confidence"] for p in predictions]

    final_label = Counter(labels).most_common(1)[0][0]

    average_confidence = sum(confidences)/len(confidences)

    severity = SEVERITY_RULES.get(
        final_label,
        "Medium"
    )

    best_prediction = max(
        predictions,
        key=lambda p: p["confidence"]
    )

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

    "hazard": best_prediction["class"],

    "confidence": round(
        best_prediction["confidence"],
        3
    ),

    "severity": SEVERITY_RULES.get(
        best_prediction["class"],
        "Medium"
    ),

    "zone": features["zone"],

    "boxes": predictions,

    "hazards": all_hazards
}