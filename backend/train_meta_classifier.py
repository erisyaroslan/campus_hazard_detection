import pandas as pd
import numpy as np

from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import accuracy_score
from dataset_builder import HEADER
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense
from tensorflow.keras.utils import to_categorical

df = pd.read_csv(
    "meta_classifier_training.csv",
    header=None
)
df.columns = HEADER

X = df.drop(columns=["label"]).values
y = df["label"].values

encoder = LabelEncoder()
y = encoder.fit_transform(y)
y = to_categorical(y)

X_train, X_test, y_train, y_test = train_test_split(

    X,
    y,
    test_size=0.2,
    random_state=42
)

model = Sequential()
model.add(Dense(32, activation="relu", input_shape=(X.shape[1],)))
model.add(Dense(16, activation="relu"))
model.add(Dense(y.shape[1], activation="softmax"))

model.compile(

    optimizer="adam",
    loss="categorical_crossentropy",
    metrics=["accuracy"]

)

history = model.fit(

    X_train,
    y_train,
    epochs=50,
    batch_size=8,
    validation_split=0.2
)

pred = model.predict(X_test)
pred = np.argmax(pred, axis=1)
actual = np.argmax(y_test, axis=1)
print("Accuracy:", accuracy_score(actual, pred))

model.save("meta_classifier.keras")

import pickle

with open("label_encoder.pkl", "wb") as f:
    pickle.dump(encoder, f)