import google.generativeai as genai
import os
from dotenv import load_dotenv

load_dotenv()

genai.configure(
    api_key=os.getenv("GEMINI_API_KEY"))

model = genai.GenerativeModel(
    "gemini-2.5-flash"
)


def get_action(
    hazard,
    category,
    zone,
    severity
):

    prompt = f"""
You are a campus maintenance assistant.

Hazard Class: {hazard}
Category: {category}
Location Zone: {zone}
Severity: {severity}

Provide a short maintenance recommendation.

Requirements:
- Maximum 2 sentences
- Practical action
- Safety focused
- Suitable for a university campus
"""

    response = model.generate_content(
        prompt
    )

    return response.text