import re
from unidecode import unidecode
from rapidfuzz import fuzz
from geopy.distance import geodesic

from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity


# =====================================================
# LOAD MULTILINGUAL EMBEDDING MODEL
# =====================================================

print("Loading multilingual embedding model...")

model = SentenceTransformer(
    "paraphrase-multilingual-MiniLM-L12-v2"
)

print("Embedding model loaded ✔")


# =====================================================
# TEXT NORMALIZATION
# =====================================================

def normalize(name):

    if not name:
        return ""

    # Arabic/French/etc → latin approximation
    name = unidecode(name)

    # lowercase
    name = name.lower()

    # remove punctuation
    name = re.sub(r"[^a-z0-9\s]", "", name)

    # normalize spaces
    name = re.sub(r"\s+", " ", name).strip()

    return name


# =====================================================
# EMBEDDING CACHE
# (VERY IMPORTANT FOR SPEED)
# =====================================================

embedding_cache = {}


def get_embedding(text):

    text = normalize(text)

    if text in embedding_cache:
        return embedding_cache[text]

    emb = model.encode(text)

    embedding_cache[text] = emb

    return emb


# =====================================================
# SEMANTIC SIMILARITY
# =====================================================

def semantic_similarity(a, b):

    emb1 = get_embedding(a)
    emb2 = get_embedding(b)

    score = cosine_similarity(
        [emb1],
        [emb2]
    )[0][0]

    return score


# =====================================================
# GEO DISTANCE
# =====================================================

def geo_distance_meters(a, b):

    try:

        return geodesic(
            (a["latitude"], a["longitude"]),
            (b["latitude"], b["longitude"])
        ).meters

    except:
        return 999999


# =====================================================
# DUPLICATE DETECTION
# =====================================================

def is_duplicate(a, b):

    name_a = a.get("name", "")
    name_b = b.get("name", "")

    if not name_a or not name_b:
        return False

    # ==========================================
    # 1. FUZZY STRING SIMILARITY
    # ==========================================

    fuzzy_score = fuzz.token_set_ratio(
        normalize(name_a),
        normalize(name_b)
    )

    # ==========================================
    # 2. SEMANTIC SIMILARITY
    # ==========================================

    semantic_score = semantic_similarity(
        name_a,
        name_b
    )

    # ==========================================
    # 3. GEO DISTANCE
    # ==========================================

    dist = geo_distance_meters(a, b)

    # ==========================================
    # 4. CATEGORY CONSISTENCY
    # ==========================================

    category_a = a.get("category")
    category_b = b.get("category")

    same_category = category_a == category_b

    # ==========================================
    # STRICT DUPLICATE RULE
    # ==========================================

    # CASE 1:
    # strong fuzzy + close geo

    if (
        fuzzy_score > 90 and
        dist < 150 and
        same_category
    ):
        return True

    # CASE 2:
    # strong semantic + close geo

    if (
        semantic_score > 0.85 and
        dist < 300 and
        same_category
    ):
        return True

    return False


# =====================================================
# MERGE TWO DUPLICATE RECORDS
# =====================================================

def merge_places(a, b):

    merged = {}

    keys = set(a.keys()) | set(b.keys())

    for key in keys:

        va = a.get(key)
        vb = b.get(key)

        # prefer non-null values
        if va and not vb:
            merged[key] = va

        elif vb and not va:
            merged[key] = vb

        # prefer longer descriptions/text
        elif isinstance(va, str) and isinstance(vb, str):

            merged[key] = (
                va if len(va) >= len(vb)
                else vb
            )

        # prefer larger lists
        elif isinstance(va, list) and isinstance(vb, list):

            merged[key] = list(
                set(va + vb)
            )

        else:
            merged[key] = va if va is not None else vb

    # preserve sources
    merged["merged_sources"] = list(set(
        [a.get("source", "unknown")] +
        [b.get("source", "unknown")]
    ))

    return merged


# =====================================================
# MAIN DEDUPLICATION PIPELINE
# =====================================================

def deduplicate(data):

    unique = []

    total = len(data)

    print(f"\nStarting deduplication on {total} places...\n")

    for idx, item in enumerate(data):

        if idx % 100 == 0:
            print(
                f"Processed {idx}/{total} "
                f"| current unique: {len(unique)}"
            )

        found_duplicate = False

        for i, existing in enumerate(unique):

            try:

                if is_duplicate(item, existing):

                    # merge records
                    unique[i] = merge_places(
                        existing,
                        item
                    )

                    found_duplicate = True
                    break

            except Exception as e:
                print(f"Dedup error: {e}")

        if not found_duplicate:
            unique.append(item)

    print("\nDeduplication completed ✔")

    print(
        f"Original: {len(data)} | "
        f"Unique: {len(unique)} | "
        f"Removed: {len(data) - len(unique)}"
    )

    return unique