import json
from tqdm import tqdm

from google_enrichment import enrich_google
from llm_enrichment import enrich_llm

from pathlib import Path
import json

from deduplication import deduplicate
from activities_opentrip import (
    get_opentrip_activities,
    enrich_activity_details
)


# ============================================
# INPUT FILES
# ============================================

BASE_DIR = Path(__file__).resolve().parent.parent

FILES = [
    BASE_DIR / "data" / "restaurants.json",
    BASE_DIR / "data" / "hotels.json",
    BASE_DIR / "data" / "activities.json"
]


# ============================================
# LOAD LOCAL DATASETS
# ============================================

def load_all_data():

    all_data = []

    for file_path in FILES:

        try:

            with open(file_path, "r", encoding="utf-8") as f:
                data = json.load(f)

            for item in data:

                item["source_file"] = file_path.name

                # normalize category
                if "restaurant" in file_path.name:
                    item["category"] = "restaurant"

                elif "hotel" in file_path.name:
                    item["category"] = "hotel"

                elif "activity" in file_path.name:
                    item["category"] = "activity"

                all_data.append(item)

            print(
                f"Loaded {len(data)} places "
                f"from {file_path.name}"
            )

        except Exception as e:

            print(
                f"Failed loading {file_path}: {e}"
            )

    return all_data


# ============================================
# ADD MISSING ACTIVITIES
# ============================================

def add_extra_activities(data):

    print("\nFetching extra activities from OpenTripMap...\n")

    try:

        extra_activities = get_opentrip_activities(
            lat=31.6295,      # Marrakech
            lon=-7.9811,
            radius=50000      # 50km around Marrakech
        )

        print(f"Found {len(extra_activities)} extra activities")

        for activity in tqdm(extra_activities):

            try:

                xid = activity.get("id")

                details = enrich_activity_details(xid)

                enriched_activity = {
                    "id": xid,
                    "name": activity.get("name"),
                    "latitude": activity.get("latitude"),
                    "longitude": activity.get("longitude"),

                    "category": "activity",

                    "description": details.get("description"),

                    "image": details.get("image"),

                    "address": details.get("address"),

                    "opentripmap_kinds": details.get("kinds"),

                    "source": "opentripmap"
                }

                data.append(enriched_activity)

            except Exception as e:
                print(f"Failed enriching activity: {e}")

    except Exception as e:
        print(f"OpenTripMap fetch failed: {e}")

    return data


# ============================================
# MAIN PIPELINE
# ============================================

def run_pipeline():

    # ========================================
    # 1. LOAD EXISTING DATA
    # ========================================

    data = load_all_data()

    print(f"\nInitial dataset size: {len(data)}")

    # ========================================
    # 2. ADD EXTRA ACTIVITIES
    # ========================================

    data = add_extra_activities(data)

    print(f"\nDataset after adding activities: {len(data)}")

    # ========================================
    # 3. REMOVE DUPLICATES
    # ========================================

    print("\nDeduplicating dataset...\n")

    before = len(data)

    data = deduplicate(data)

    after = len(data)

    print(f"Removed {before - after} duplicates")
    print(f"Dataset size after deduplication: {after}")

    # ========================================
    # 4. ENRICHMENT
    # ========================================

    enriched = []

    print("\nStarting enrichment pipeline...\n")

    for idx, place in enumerate(tqdm(data)):

        try:

            print(
                f"\n[{idx + 1}/{len(data)}] "
                f"{place.get('name')}"
            )

            # ================================
            # GOOGLE ENRICHMENT
            # ================================

            place = enrich_google(place)

            # ================================
            # LLM ENRICHMENT
            # ================================

            place = enrich_llm(place)

            enriched.append(place)

        except Exception as e:

            print(
                f"Error processing "
                f"{place.get('name')}: {e}"
            )

    # ========================================
    # 5. SAVE FINAL DATASET
    # ========================================

    with open(
        "final_dataset.json",
        "w",
        encoding="utf-8"
    ) as f:

        json.dump(
            enriched,
            f,
            indent=2,
            ensure_ascii=False
        )

    print("\n====================================")
    print("PIPELINE COMPLETED ✔")
    print(f"Final dataset size: {len(enriched)}")
    print("Saved to: final_dataset.json")
    print("====================================")


# ============================================
# ENTRYPOINT
# ============================================

if __name__ == "__main__":
    run_pipeline()