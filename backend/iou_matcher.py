from itertools import combinations


def calculate_iou(box1, box2):
    """
    box format:
    [center_x, center_y, width, height]
    """

    x1_min = box1[0] - box1[2] / 2
    y1_min = box1[1] - box1[3] / 2
    x1_max = box1[0] + box1[2] / 2
    y1_max = box1[1] + box1[3] / 2

    x2_min = box2[0] - box2[2] / 2
    y2_min = box2[1] - box2[3] / 2
    x2_max = box2[0] + box2[2] / 2
    y2_max = box2[1] + box2[3] / 2

    inter_x1 = max(x1_min, x2_min)
    inter_y1 = max(y1_min, y2_min)

    inter_x2 = min(x1_max, x2_max)
    inter_y2 = min(y1_max, y2_max)

    inter_area = max(
        0,
        inter_x2 - inter_x1
    ) * max(
        0,
        inter_y2 - inter_y1
    )

    area1 = (x1_max - x1_min) * (y1_max - y1_min)
    area2 = (x2_max - x2_min) * (y2_max - y2_min)

    union = area1 + area2 - inter_area

    if union == 0:
        return 0

    return inter_area / union

def match_boxes(predictions, threshold=0.5):

    matched = []

    used = set()

    for i, j in combinations(range(len(predictions)), 2):

        if i in used or j in used:
            continue

        p1 = predictions[i]
        p2 = predictions[j]

        if p1["class"] != p2["class"]:
            continue

        iou = calculate_iou(
            p1["bbox"],
            p2["bbox"]
        )

        if iou >= threshold:

            confidence = max(
                p1["confidence"],
                p2["confidence"]
            )

            matched.append({

                "class": p1["class"],

                "confidence": confidence,

                "bbox": p1["bbox"],

                "models": [
                    p1["model"],
                    p2["model"]
                ]
            })

            used.add(i)
            used.add(j)

    for k, p in enumerate(predictions):

        if k not in used:

            matched.append({

                "class": p["class"],

                "confidence": p["confidence"],

                "bbox": p["bbox"],

                "models": [
                    p["model"]
                ]
            })

    return matched