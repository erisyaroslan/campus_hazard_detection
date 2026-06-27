def build_features(
        predictions,
        zone
):

    confidences = []

    labels = []

    models = []

    for p in predictions:

        confidences.append(
            p["confidence"]
        )

        labels.append(
            p["class"]
        )

        models.extend(
            p["models"]
        )

    if len(predictions) == 0:
        return {
            "average_confidence": 0,
            "agreement_count": 0,
            "zone": zone
         }
    

    average_confidence = (
        sum(confidences)
        / len(confidences)
    )

    agreement_count = len(labels)

    feature_vector = {

        "average_confidence":
            round(
                average_confidence,
                3
            ),

        "agreement_count":
            agreement_count,

        "zone":
            zone,

        "labels":
            labels,

        "models":
            models
    }

    return feature_vector