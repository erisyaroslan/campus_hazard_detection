import json
import os
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