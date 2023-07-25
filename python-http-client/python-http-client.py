import requests

url = "http://127.0.0.1:8000/get"

for i in range(100):
    response = requests.get(url)
    print(f"{i + 1} {response.text}")
