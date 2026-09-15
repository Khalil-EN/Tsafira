import json
import time
import re

from rapidfuzz import fuzz
from bs4 import BeautifulSoup

from playwright.sync_api import sync_playwright

from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
INPUT_FILE = BASE_DIR / "data" / "restaurants.json"
OUTPUT_FILE = BASE_DIR / "data" / "enriched_restaurants.json"

MAX_RESULTS = 5


def normalize_text(text):
    if not text:
        return ""

    return re.sub(r"\s+", " ", text).strip().lower()


def similarity(a, b):
    return fuzz.token_sort_ratio(
        normalize_text(a),
        normalize_text(b)
    )


def extract_text(element):
    if not element:
        return None

    return element.get_text(strip=True)


def enrich_restaurant(page, restaurant):

    query = f"{restaurant['name']} Marrakech TripAdvisor"

    print(f"\nSearching: {query}")

    search_url = (
        "https://www.google.com/search?q="
        + query.replace(" ", "+")
    )

    page.goto(search_url)

    page.wait_for_timeout(3000)

    links = page.locator("a").evaluate_all("""
        els => els.map(e => e.href)
    """)

    tripadvisor_links = []

    for link in links:
        if "tripadvisor." in link:
            tripadvisor_links.append(link)

    if not tripadvisor_links:
        print("No TripAdvisor result")
        return restaurant

    tripadvisor_url = tripadvisor_links[0]

    print("Opening:", tripadvisor_url)

    try:
        page.goto(
            tripadvisor_url,
            timeout=60000
        )

        page.wait_for_timeout(5000)

    except Exception as e:
        print("Failed:", e)
        return restaurant

    html = page.content()

    soup = BeautifulSoup(html, "html.parser")

    enriched = restaurant.copy()

    text = soup.get_text(" ", strip=True)

    # -------------------------
    # Rating
    # -------------------------

    rating_match = re.search(
        r"([0-5]\.[0-9])\s+of\s+5",
        text
    )

    if rating_match:
        enriched["rating"] = float(
            rating_match.group(1)
        )

    # -------------------------
    # Review count
    # -------------------------

    review_match = re.search(
        r"([\d,]+)\s+Reviews",
        text,
        re.IGNORECASE
    )

    if review_match:
        enriched["review_count"] = int(
            review_match.group(1).replace(",", "")
        )

    # -------------------------
    # Price range
    # -------------------------

    price_match = re.search(
        r"(\$\$?\$?)",
        text
    )

    if price_match:
        enriched["price_range"] = (
            price_match.group(1)
        )

    # -------------------------
    # Features extraction
    # -------------------------

    FEATURES = [
        "vegan options",
        "vegetarian friendly",
        "gluten free options",
        "outdoor seating",
        "delivery",
        "takeout",
        "reservations",
        "free wifi",
        "credit cards",
        "live music"
    ]

    found_features = []

    lower_text = text.lower()

    for feature in FEATURES:

        if feature in lower_text:
            found_features.append(feature)

    enriched["features"] = found_features

    # -------------------------
    # Cuisine extraction
    # -------------------------

    CUISINES = [
        "moroccan",
        "mediterranean",
        "african",
        "french",
        "italian",
        "international",
        "middle eastern",
        "cafe"
    ]

    cuisines_found = []

    for cuisine in CUISINES:

        if cuisine in lower_text:
            cuisines_found.append(cuisine)

    enriched["cuisines"] = cuisines_found

    # -------------------------
    # Description
    # -------------------------

    paragraphs = soup.find_all("p")

    descriptions = []

    for p in paragraphs:

        txt = extract_text(p)

        if txt and len(txt) > 80:
            descriptions.append(txt)

    if descriptions:
        enriched["description"] = descriptions[0]

    enriched["enriched_source"] = tripadvisor_url

    return enriched


def main():

    with open(
        INPUT_FILE,
        "r",
        encoding="utf-8"
    ) as f:

        restaurants = json.load(f)

    enriched_restaurants = []

    with sync_playwright() as p:

        browser = p.chromium.launch(
            headless=False
        )

        page = browser.new_page()

        for idx, restaurant in enumerate(restaurants):

            try:

                print(
                    f"\n[{idx+1}/{len(restaurants)}]"
                )

                enriched = enrich_restaurant(
                    page,
                    restaurant
                )

                enriched_restaurants.append(
                    enriched
                )

                time.sleep(5)

            except Exception as e:

                print("Error:", e)

        browser.close()

    with open(
        OUTPUT_FILE,
        "w",
        encoding="utf-8"
    ) as f:

        json.dump(
            enriched_restaurants,
            f,
            indent=2,
            ensure_ascii=False
        )

    print(
        f"\nSaved enriched data "
        f"to {OUTPUT_FILE}"
    )


if __name__ == "__main__":
    main()