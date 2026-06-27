from model_runner import run_all_models

from harmonizer import (
    harmonize_predictions,
    get_category
)

from feature_builder import (
    build_features
)

from meta_classifier import (
    classify
)

from llm import (
    get_action
)


# STEP 1: Run all YOLO models
predictions = run_all_models(
    "images/test_b.jpeg"
)

print("RAW PREDICTIONS:")
print(predictions)
print()


# STEP 2: Harmonise labels
predictions = harmonize_predictions(
    predictions
)

print("HARMONISED PREDICTIONS:")
print(predictions)
print()


# STEP 3: Build feature vector
features = build_features(
    predictions,
    "Campus Road"
)

print("FEATURE VECTOR:")
print(features)
print()


# STEP 4: Meta-classifier
result = classify(
    predictions,
    features
)

print("META CLASSIFIER RESULT:")
print(result)
print()


# STEP 5: Get category
category = get_category(
    result["hazard"]
)

print("CATEGORY:")
print(category)
print()


# STEP 6: Gemini recommendation
action = get_action(
    result["hazard"],
    category,
    result["zone"],
    result["severity"]
)

print("RECOMMENDED ACTION:")
print(action)