import json
import os
import csv
from datetime import datetime

LOG_FILE = "logs/detections.json"

def save_detection(record):

    record["timestamp"] = datetime.now().strftime(
        "%Y-%m-%d %H:%M:%S"
    )

    if os.path.exists(LOG_FILE):

        with open(
            LOG_FILE,
            "r"
        ) as f:

            data = json.load(f)

    else:

        data = []

    data.append(record)

    with open(
        LOG_FILE,
        "w"
    ) as f:

        json.dump(
            data,
            f,
            indent=4
        )

def save_training_data(features, final_label):

    file = "meta_classifier_training.csv"

    exists = os.path.exists(file)

    with open(file, "a", newline="") as f:

        writer = csv.writer(f)

        if not exists:
            writer.writerow([
                "average_confidence",
                "agreement_count",
                "zone",
                "label"
            ])

        writer.writerow([
            features["average_confidence"],
            features["agreement_count"],
            features["zone"],
            final_label
        ])