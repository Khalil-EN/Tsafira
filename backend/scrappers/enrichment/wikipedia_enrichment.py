import requests

def enrich_wikipedia(place):

    name = place.get("name")
    if not name:
        return place

    url = f"https://en.wikipedia.org/api/rest_v1/page/summary/{name.replace(' ', '_')}"

    r = requests.get(url)

    if r.status_code != 200:
        return place

    data = r.json()

    place["description"] = data.get("extract")
    place["wiki_url"] = data.get("content_urls", {}).get("desktop", {}).get("page")

    return place