import requests

response = requests.post(

    "http://127.0.0.1:5000/predict",

    json={
        "zone": "Campus Road",
        "image_path": "images/test_b.jpeg"
    }
)

print(response.status_code)
print(response.json())