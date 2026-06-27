def calculate_iou(box1, box2):

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

    area1 = (
        x1_max - x1_min
    ) * (
        y1_max - y1_min
    )

    area2 = (
        x2_max - x2_min
    ) * (
        y2_max - y2_min
    )

    union = area1 + area2 - inter_area

    if union == 0:
        return 0

    return inter_area / union

def match_boxes(predictions):

    matches = []

    for i in range(len(predictions)):

        for j in range(i + 1, len(predictions)):

            iou = calculate_iou(
                predictions[i]["bbox"],
                predictions[j]["bbox"]
            )

            if iou >= 0.5:

                matches.append({

                    "prediction_1":
                        predictions[i],

                    "prediction_2":
                        predictions[j],

                    "iou":
                        round(iou, 3)
                })
    return matches