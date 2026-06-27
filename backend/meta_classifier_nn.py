import joblib

model = joblib.load(
    "meta_classifier.pkl"
)

def predict(features):

    x = [[
        features["average_confidence"],
        features["agreement_count"]
    ]]

    return model.predict(x)[0]