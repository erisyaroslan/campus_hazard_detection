from model_runner import run_all_models
from harmonizer import harmonize_predictions
from feature_builder import build_features
from meta_classifier import classify

predictions = run_all_models(
    "images/test_b.jpeg"
)

predictions = harmonize_predictions(
    predictions
)

features = build_features(
    predictions,
    "Campus Road"
)

result = classify(
    predictions,
    features
)

print(result)