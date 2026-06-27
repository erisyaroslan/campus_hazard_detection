ZONE_MAP = {
    "Campus Road": 0,
    "Faculty Road": 1,
    "Parking Area": 2,
    "Cafeteria Area": 3,
    "Student Residential Area": 4
}

LABEL_MAP = {
    "Pothole":0,
    "Sunk Road":1,
    "Crack Pavement":2,
    "Open Drain":3,
    "Uncovered Manhole":4,
    "Broken Fence":5,
    "Missing Barricade":6,
    "Open Restricted Area":7,
    "Sharp Object":8,
    "Exposed Live Wire":9,
    "Dangling Wire":10,
    "Broken Socket":11,
    "Damaged Electrical Box":12
}

def build_features(predictions, zone):

    confidences = [p["confidence"] for p in predictions]

    average_confidence = sum(confidences) / len(confidences)

    agreement_count = len(predictions)

    label_counts = [0] * 13

    modelA = 0
    modelB = 0
    modelC = 0

    for p in predictions:

        label = p["class"]

        if label in LABEL_MAP:
            label_counts[LABEL_MAP[label]] += 1

        for m in p["models"]:
            if m == "A":
                modelA += 1
            elif m == "B":
                modelB += 1
            elif m == "C":
                modelC += 1

    return [
        average_confidence,
        agreement_count,
        ZONE_MAP[zone],   
        modelA,
        modelB,
        modelC,
        *label_counts
    ]