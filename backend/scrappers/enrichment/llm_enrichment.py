import ollama
import json

MODEL = "qwen2.5:3b"


def enrich_llm(place):

    prompt = f"""
You are a travel data enrichment system.

You will enrich a tourism place.

IMPORTANT RULES:
- If a real description is missing, create a realistic one.
- Do NOT invent specific historical facts.
- Keep it short and useful for travelers.

Place:
Name: {place.get('name')}
Category: {place.get('category')}
Existing description: {place.get('description')}
Location: {place.get('latitude')}, {place.get('longitude')}

Return ONLY valid JSON:

{{
  "description": "...",
  "tags": ["..."],
  "vibe": "...",
  "recommended_duration": "...",
  "travel_styles": ["..."],
  "is_vegan_friendly": true,
  "is_family_friendly": true,
  "budget_level": "budget|medium|luxury"
}}
"""

    try:

        response = ollama.chat(
            model=MODEL,
            messages=[{"role": "user", "content": prompt}],
            format="json",
            options={"temperature": 0.3}
        )

        data = json.loads(response["message"]["content"])

        # only overwrite description if missing
        if not place.get("description"):
            place["description"] = data.get("description")

        place.update({k: v for k, v in data.items() if k != "description"})

    except Exception as e:
        print(f"LLM failed for {place.get('name')}: {e}")

    return place