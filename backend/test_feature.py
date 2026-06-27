from model_runner import run_all_models

from feature_builder import build_features

predictions = run_all_models(
    "images/test_b.jpeg"
)

features = build_features(
    predictions,
    "Campus Road"
)

print(features)