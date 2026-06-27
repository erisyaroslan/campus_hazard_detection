import csv
import os

CSV_FILE = "meta_classifier_training.csv"

HEADER = [
    "avg_confidence",
    "agreement",
    "zone",
    "modelA",
    "modelB",
    "modelC",

    "Pothole",
    "Sunk Road",
    "Crack Pavement",
    "Open Drain",
    "Uncovered Manhole",
    "Broken Fence",
    "Missing Barricade",
    "Open Restricted Area",
    "Sharp Object",
    "Exposed Live Wire",
    "Dangling Wire",
    "Broken Socket",
    "Damaged Electrical Box",

    "label"
]


def save_training_sample(features, label):

    file_exists = os.path.exists(CSV_FILE)

    with open(CSV_FILE, "a", newline="") as f:

        writer = csv.writer(f)

        if not file_exists:
            writer.writerow(HEADER)

        writer.writerow(features + [label])