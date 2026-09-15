import requests

API_KEY = "AIzaSyD-vddcJHjBKJWhu-QJIV96bEgZw5r3AIQ"

def build_photo_url(photo_reference, maxwidth=800):

    return (
        "https://maps.googleapis.com/maps/api/place/photo"
        f"?maxwidth={maxwidth}"
        f"&photo_reference={photo_reference}"
        f"&key={API_KEY}"
    )

def nearby_search(place):

    url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"

    params = {
        "key": API_KEY,
        "location": f"{place['latitude']},{place['longitude']}",
        "radius": 150,
        "keyword": place["name"]
    }

    r = requests.get(url, params=params)
    data = r.json()

    if not data.get("results"):
        return None

    return data["results"][0]["place_id"]


def place_details(place_id):

    url = "https://maps.googleapis.com/maps/api/place/details/json"

    fields = ",".join([
        "name",
        "rating",
        "user_ratings_total",
        "price_level",
        "types",
        "business_status",
        "formatted_address",
        "formatted_phone_number",
        "international_phone_number",
        "website",
        "url",
        "opening_hours",
        "reviews",
        "photos",
        "geometry"
    ])

    params = {
        "key": API_KEY,
        "place_id": place_id,
        "fields": fields
    }

    r = requests.get(url, params=params)
    return r.json().get("result", {})

def enrich_google(place):

    if not place.get("latitude"):
        return place

    place_id = nearby_search(place)

    if not place_id:
        return place

    details = place_details(place_id)

    if not details:
        return place

    # =====================
    # CORE SIGNALS
    # =====================
    place["rating"] = details.get("rating")
    place["review_count"] = details.get("user_ratings_total")
    place["price_level"] = details.get("price_level")
    place["google_types"] = details.get("types", [])

    # =====================
    # IDENTITY
    # =====================
    place["google_name"] = details.get("name")
    place["business_status"] = details.get("business_status")

    # =====================
    # LOCATION
    # =====================
    place["address"] = details.get("formatted_address")
    place["google_maps_url"] = details.get("url")

    # =====================
    # CONTACT
    # =====================
    place["phone"] = details.get("formatted_phone_number")
    place["international_phone"] = details.get("international_phone_number")
    place["website"] = details.get("website")

    # =====================
    # HOURS
    # =====================
    place["opening_hours"] = details.get("opening_hours")

    # =====================
    # REVIEWS (VERY IMPORTANT)
    # =====================
    if "reviews" in details:
        place["reviews_sample"] = [
            {
                "rating": r.get("rating"),
                "text": r.get("text")
            }
            for r in details["reviews"]
        ]

    # =====================
    # PHOTOS (optional)
    # =====================
    if "photos" in details:

        place["photos"] = [
            build_photo_url(p.get("photo_reference"), 800)
            for p in details["photos"][:5]
            if p.get("photo_reference")
        ]

    return place