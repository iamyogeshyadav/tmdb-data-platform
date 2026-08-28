from __future__ import annotations
import requests

class TMBDClient():

    BASE_URL = "https://api.themoviedb.org/3"

    def __init__(self,bearer_token: str) -> None:
        if not bearer_token:
            raise ValueError("TMBD Bearer token must not be empty")

        self.bearer_token= bearer_token

    def fetch_movies(self, endpoint: str, page: int=1) -> dict:
        url = f"{self.BASE_URL}/movie/{endpoint}"
        headers = {
            "Accept": "application/json",
            "Authorization": "Bearer {self.bearer_token}"
    
        }
        params = {
                "language": "en-US",
                "page": page,
            }

        response = requests.get(
            url,
            headers=headers,
            params=params,
            timeout=30,
        )

        response.raise_for_status()

        return response.json()