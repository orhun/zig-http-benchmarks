import requests

url = "http://127.0.0.1:8000/get"
s = requests.Session()

for i in range(1000):
    response = s.get(url, headers={"connection": "keep-alive"})
    print(f"{i + 1} {response.text}")
