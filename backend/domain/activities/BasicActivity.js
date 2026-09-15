const ActivityTypeEnum = require('./enums/ActivityTypeEnum');

class Activity {
    constructor({
        id,
        name,
        description,
        activityType,
        numberOfReviews,
        rating,
        image,
        address,
        longitude,
        latitude,
        price,
    }) {
        this.id = id ?? null;

        this.name = name ?? '';
        this.description = description ?? '';

        this.activityType = activityType ?? null;

        this.numberOfReviews = Number.isFinite(Number(numberOfReviews))
            ? Number(numberOfReviews)
            : 0;

        this.rating = Number.isFinite(Number(rating))
            ? Number(rating)
            : 0;

        this.image = image ?? null;

        this.address = address ?? null;

        this.longitude = longitude ?? null;
        this.latitude = latitude ?? null;

        // Activity price is PER PERSON.
        this.price = Number.isFinite(Number(price))
            ? Number(price)
            : null;
    }

    getCoordinates() {
        return {
            lat: this.latitude,
            lng: this.longitude,
        };
    }

    getPricePerPerson() {
        return this.price;
    }

    getEstimatedCost(numberOfPeople) {
        if (!Number.isFinite(this.price)) {
            return null;
        }

        if (!Number.isFinite(numberOfPeople) || numberOfPeople <= 0) {
            return null;
        }

        return this.price * numberOfPeople;
    }

    isValidLocation() {
        return (
            Number.isFinite(Number(this.latitude)) &&
            Number.isFinite(Number(this.longitude))
        );
    }

    toJSON() {
        return {
            id: this.id,
            name: this.name,
            description: this.description,
            activityType: this.activityType,
            numberOfReviews: this.numberOfReviews,
            rating: this.rating,
            image: this.image,
            address: this.address,
            longitude: this.longitude,
            latitude: this.latitude,
            price: this.price,
        };
    }

    static normalizeTypes(labels) {
        return ActivityTypeEnum.normalizeAll(labels);
    }
}

module.exports = Activity;