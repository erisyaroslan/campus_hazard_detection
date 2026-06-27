LABEL_MAP = {

    "broken_socket":
        "Broken Socket",

    "dangling_wire":
        "Dangling Wire",

    "exposed_live_wire":
        "Exposed Live Wire",

    "damaged_electrical_box":
        "Damaged Electrical Box",

    "open_restricted_area":
        "Open Restricted Area",

    "uncovered_manhole":
        "Uncovered Manhole",

    "sunk_road":
        "Sunk Road",

    "pothole":
        "Pothole",

    "open_drain":
        "Open Drain",

    "crack_pavement":
        "Crack Pavement",

    "broken_fence":
        "Broken Fence",

    "missing_barricade":
        "Missing Barricade",

    "sharp_object":
        "Sharp Object"
}

CATEGORY_MAP = {

    "Broken Socket":
        "Electrical Hazard",

    "Dangling Wire":
        "Electrical Hazard",

    "Exposed Live Wire":
        "Electrical Hazard",

    "Damaged Electrical Box":
        "Electrical Hazard",

    "Open Restricted Area":
        "Access Hazard",

    "Uncovered Manhole":
        "Ground Hazard",

    "Sunk Road":
        "Road Hazard",

    "Pothole":
        "Road Hazard",

    "Open Drain":
        "Ground Hazard",

    "Crack Pavement":
        "Road Hazard",

    "Broken Fence":
        "Boundary Hazard",

    "Missing Barricade":
        "Boundary Hazard",

    "Sharp Object":
        "Safety Hazard"
}

SEVERITY_RULES = {

    "Exposed Live Wire":
        "High",

    "Dangling Wire":
        "High",

    "Broken Socket":
        "High",

    "Damaged Electrical Box":
        "High",

    "Uncovered Manhole":
        "High",

    "Open Drain":
        "High",

    "Sharp Object":
        "Medium",

    "Broken Fence":
        "Medium",

    "Missing Barricade":
        "Medium",

    "Pothole":
        "Medium",

    "Sunk Road":
        "Medium",

    "Crack Pavement":
        "Low",

    "Open Restricted Area":
        "Medium"
}


def harmonize(label):

    return LABEL_MAP.get(
        label.lower(),
        label
    )


def get_category(hazard):

    return CATEGORY_MAP.get(
        hazard,
        "Unknown"
    )

def harmonize_predictions(predictions):

    for p in predictions:

        p["class"] = harmonize(
            p["class"]
        )

    return predictions