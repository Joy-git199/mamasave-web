from fastapi import FastAPI
from pydantic import BaseModel
import numpy as np
import joblib
from joblib import load

# Load the saved model and label encoder
pipeline, label_encoder = load("risk_model.joblib")

# Initialize the FastAPI app
app = FastAPI()

#  Define the input schema
class RiskFeatures(BaseModel):
    HeartRate: float
    BodyTemp: float
    BloodOxygen: float
    ContractionFreq: float
    ContractionIntensity: float

#  Define the prediction route
@app.post("/predict")
def predict(data: RiskFeatures):
    input_data = [[
        data.HeartRate,
        data.BodyTemp,
        data.BloodOxygen,
        data.ContractionFreq,
        data.ContractionIntensity
    ]]

    # Predict and get probabilities
    prediction = pipeline.predict(input_data)
    probs = pipeline.predict_proba(input_data)

    # Convert the predicted label
    predicted_label = label_encoder.inverse_transform(prediction)[0]

    # Convert probability results to regular floats
    probabilities = {
        str(label): float(prob)
        for label, prob in zip(label_encoder.classes_, probs[0])
    }

    return {
        "predicted_risk": predicted_label,
        "probabilities": probabilities
    }
