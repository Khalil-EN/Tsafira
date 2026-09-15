class Residence {
    constructor({
        id,
        name,
        description,
        address,
        priceRange,
        rating,
        numberOfReviews,
        checkInDate,
        checkOutDate,
        image,
        secondaryImages,
        longitude,
        latitude,
        contactInfo,
        amenities,
    }) {
        this.id = id ?? null;

        this.name = name ?? '';
        this.description = description ?? '';

        this.address = address ?? null;

        // PRICE = one room / one night
        this.priceRange = Number.isFinite(Number(priceRange))
            ? Number(priceRange)
            : null;

        this.rating = Number.isFinite(Number(rating))
            ? Number(rating)
            : 0;

        this.numberOfReviews = Number.isFinite(Number(numberOfReviews))
            ? Number(numberOfReviews)
            : 0;

        this.checkInDate = checkInDate ?? null;
        this.checkOutDate = checkOutDate ?? null;

        this.image = image ?? null;

        this.secondaryImages = Array.isArray(secondaryImages)
            ? secondaryImages
            : [];

        this.longitude = longitude ?? null;
        this.latitude = latitude ?? null;

        this.contactInfo = contactInfo ?? null;

        this.amenities = Array.isArray(amenities)
            ? amenities
            : [];
    }

    getCoordinates() {
        return {
            lat: this.latitude,
            lng: this.longitude,
        };
    }

    getNightlyRoomPrice() {
        return this.priceRange;
    }

    getEstimatedAccommodationCost({
        nights,
        rooms,
    }) {
        const price = Number(this.priceRange);
        const numberOfNights = Number(nights);
        const numberOfRooms = Number(rooms);

        if (!Number.isFinite(price) || price <= 0) {
            return null;
        }

        if (
            !Number.isFinite(numberOfNights) ||
            numberOfNights <= 0
        ) {
            return null;
        }

        if (
            !Number.isFinite(numberOfRooms) ||
            numberOfRooms <= 0
        ) {
            return null;
        }

        return (
            price *
            numberOfNights *
            numberOfRooms
        );
    }

    hasAmenity(amenity) {
        if (!amenity) {
            return false;
        }

        return this.amenities.some(
            item =>
                typeof item === 'string' &&
                item.toLowerCase() === amenity.toLowerCase()
        );
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
            address: this.address,
            priceRange: this.priceRange,
            rating: this.rating,
            numberOfReviews: this.numberOfReviews,
            checkInDate: this.checkInDate,
            checkOutDate: this.checkOutDate,
            image: this.image,
            secondaryImages: this.secondaryImages,
            longitude: this.longitude,
            latitude: this.latitude,
            contactInfo: this.contactInfo,
            amenities: this.amenities,
        };
    }
}

module.exports = Residence;