import osmnx as ox
import json
from shapely.geometry import Point

CITY = "Marrakech, Morocco"

ACTIVITY_TAGS = {
    "tourism": [
        "attraction",
        "museum",
        "gallery",
        "zoo",
        "theme_park",
        "viewpoint"
    ],

    "leisure": [
        "park",
        "garden",
        "water_park",
        "horse_riding"
    ],

    "natural": True,

    "historic": True
}

OUTPUTS = {
    "hotels": {
        "tags": {
            "tourism": "hotel"
        },
        "file": "hotels.json"
    },

    "restaurants": {
        "tags": {
            "amenity": "restaurant"
        },
        "file": "restaurants.json"
    },

    "activities": {
        "tags": ACTIVITY_TAGS,
        "file": "activities.json"
    }
}


def safe_get(row, key):
    value = row.get(key)

    if value is None:
        return None

    try:
        if str(value) == "nan":
            return None
    except:
        pass

    return value


def extract_coordinates(geometry):
    try:
        if geometry.geom_type == "Point":
            return geometry.y, geometry.x

        centroid = geometry.centroid
        return centroid.y, centroid.x

    except:
        return None, None


def normalize_place(row, category):

    lat, lon = extract_coordinates(row.geometry)

    return {
        "id": str(safe_get(row, "osmid")),

        "name": safe_get(row, "name"),

        "category": category,

        "description": safe_get(row, "description"),

        "latitude": lat,
        "longitude": lon,

        "address": {
            "street": safe_get(row, "addr:street"),
            "housenumber": safe_get(row, "addr:housenumber"),
            "postcode": safe_get(row, "addr:postcode"),
            "city": CITY
        },

        "contact": {
            "phone": safe_get(row, "phone"),
            "email": safe_get(row, "email"),
            "website": safe_get(row, "website")
        },

        "metadata": {
            "opening_hours": safe_get(row, "opening_hours"),
            "cuisine": safe_get(row, "cuisine"),
            "stars": safe_get(row, "stars"),
            "internet_access": safe_get(row, "internet_access"),
            "wheelchair": safe_get(row, "wheelchair"),
            "smoking": safe_get(row, "smoking"),
            "outdoor_seating": safe_get(row, "outdoor_seating"),
            "tourism": safe_get(row, "tourism"),
            "amenity": safe_get(row, "amenity")
        },

        "source": "openstreetmap"
    }


for category, config in OUTPUTS.items():

    print(f"\nFetching {category}...")

    gdf = ox.features_from_place(
        CITY,
        tags=config["tags"]
    )

    places = []

    for idx, row in gdf.iterrows():

        try:
            place = normalize_place(row, category)

            # skip entries without names
            if not place["name"]:
                continue

            places.append(place)

        except Exception as e:
            print("Error:", e)

    with open(
        config["file"],
        "w",
        encoding="utf-8"
    ) as f:

        json.dump(
            places,
            f,
            indent=2,
            ensure_ascii=False
        )

    print(
        f"Saved {len(places)} {category} "
        f"to {config['file']}"
    )