from sklearn.neural_network import MLPClassifier
import joblib

model = MLPClassifier(
    hidden_layer_sizes=(20,10),
    max_iter=1000
)

model.fit(X,y)

joblib.dump(
    model,
    "meta_classifier.pkl"
)