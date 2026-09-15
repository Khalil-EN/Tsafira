const PriceLevelEnum = require('./enums/PriceLevelEnum');

class Restaurant {
    constructor({
        id,
        name,
        address,
        priceLevel,
        rating,
        numberOfReviews,
        openingHours,
        image,
        longitude,
        latitude,
        contactInfo,
        description,
        facilities,
        meals,
        images,
        tags,
        cuisines,
    }) {
        this.id = id ?? null;

        this.name = name ?? '';
        this.address = address ?? null;
        this.description = description ?? '';

        this.priceLevel = priceLevel ?? null;

        this.rating = Number.isFinite(Number(rating))
            ? Number(rating)
            : 0;

        this.numberOfReviews = Number.isFinite(Number(numberOfReviews))
            ? Number(numberOfReviews)
            : 0;

        this.openingHours = openingHours ?? null;
        this.contactInfo = contactInfo ?? null;

        this.image = image ?? null;

        this.images = Array.isArray(images)
            ? images
            : [];

        this.longitude = longitude ?? null;
        this.latitude = latitude ?? null;

        this.cuisines = Array.isArray(cuisines)
            ? cuisines
            : [];

        this.facilities = Array.isArray(facilities)
            ? facilities
            : [];

        this.meals = Array.isArray(meals)
            ? meals.map(meal => String(meal).toLowerCase())
            : [];

        this.tags = Array.isArray(tags)
            ? tags
            : [];
    }

    getCoordinates() {
        return {
            lat: this.latitude,
            lng: this.longitude,
        };
    }

    /**
     * Returns the estimated price PER PERSON.
     *
     * Example:
     * "$$" -> 100
     * "$$-$$$" -> 150
     */
    getPricePerPerson() {
        return PriceLevelEnum.toNumeric(this.priceLevel);
    }

    /**
     * Returns estimated total restaurant cost
     * for the whole group.
     */
    getEstimatedMealCost(numberOfPeople) {
        const pricePerPerson = this.getPricePerPerson();

        if (pricePerPerson === null) {
            return null;
        }

        if (!Number.isFinite(numberOfPeople) || numberOfPeople <= 0) {
            return null;
        }

        return pricePerPerson * numberOfPeople;
    }

    servesMeal(meal) {
        if (!meal) {
            return false;
        }

        const normalizedMeal = String(meal).toLowerCase();

        return this.meals.includes(normalizedMeal);
    }

    hasTag(tag) {
        if (!tag) {
            return false;
        }

        return this.tags.some(
            item =>
                typeof item === 'string' &&
                item.toLowerCase() === tag.toLowerCase()
        );
    }

    hasFacility(facility) {
        if (!facility) {
            return false;
        }

        return this.facilities.some(
            item =>
                typeof item === 'string' &&
                item.toLowerCase() === facility.toLowerCase()
        );
    }

    isValidLocation() {
        return (
            Number.isFinite(Number(this.latitude)) &&
            Number.isFinite(Number(this.longitude))
        );
    }

    numericPrice() {
        return this.getPricePerPerson();
    }

    toJSON() {
        return {
            id: this.id,
            name: this.name,
            address: this.address,
            priceLevel: this.priceLevel,
            rating: this.rating,
            numberOfReviews: this.numberOfReviews,
            openingHours: this.openingHours,
            image: this.image,
            longitude: this.longitude,
            latitude: this.latitude,
            contactInfo: this.contactInfo,
            description: this.description,
            facilities: this.facilities,
            meals: this.meals,
            images: this.images,
            tags: this.tags,
            cuisines: this.cuisines,
        };
    }

    static cleanCuisineTypes(cuisines) {
        if (!Array.isArray(cuisines)) {
            return [];
        }

        return cuisines
            .filter(item => typeof item === 'string')
            .map(item =>
                item
                    .split(' ')[0]
                    .toLowerCase()
            );
    }

    static fromPriceRange(minPrice, maxPrice) {
        return PriceLevelEnum.fromRange(
            minPrice,
            maxPrice
        );
    }
}

module.exports = Restaurant;