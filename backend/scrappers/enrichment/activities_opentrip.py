import requests

API_KEY = "5ae2e3f221c38a28845f05b685b2b86fc6c91826811160a371abbf55"


def get_opentrip_activities(lat=31.6295, lon=-7.9811, radius=30000):

    url = "https://api.opentripmap.com/0.1/en/places/radius"

    params = {
        "apikey": API_KEY,
        "radius": radius,
        "lon": lon,
        "lat": lat,
        "rate": 2,
        "format": "json"
    }

    r = requests.get(url, params=params)
    data = r.json()

    activities = []

    for item in data:

        activities.append({
            "id": item.get("xid"),
            "name": item.get("name"),
            "latitude": item.get("point", {}).get("lat"),
            "longitude": item.get("point", {}).get("lon"),
            "category": item.get("kinds"),
            "source": "opentripmap"
        })

    return activities

def enrich_activity_details(xid):

    url = f"https://api.opentripmap.com/0.1/en/places/xid/{xid}"

    params = {"apikey": API_KEY}

    r = requests.get(url, params=params)
    data = r.json()

    return {
        "description": data.get("wikipedia_extracts", {}).get("text"),
        "image": data.get("preview", {}).get("source"),
        "rating": data.get("rate"),
        "address": data.get("address", {}),
        "kinds": data.get("kinds")
    }