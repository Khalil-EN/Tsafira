const ResidenceScorer = require('./ResidenceScorer');
const RoomCapacityPolicy = require('../RoomCapacityPolicy');

class WeightedResidenceScorer extends ResidenceScorer {
    constructor({
        maxBudget = 0,
        nights = 1,
        numberOfPeople = 1,
        minRating = 0,
        preferredAmenities = [],
        weight = {
            price: 0.4,
            rating: 0.3,
            amenities: 0.1,
            reviews: 0.2,
        },
    } = {}) {
        super();

        this.maxBudget = Number(maxBudget) || 0;
        this.nights = Number(nights) || 1;
        this.numberOfPeople = Number(numberOfPeople) || 1;
        this.minRating = Number(minRating) || 0;

        this.preferredAmenities = Array.isArray(preferredAmenities)
            ? preferredAmenities
            : [];

        this.weight = {
            price: Number(weight.price) || 0,
            rating: Number(weight.rating) || 0,
            amenities: Number(weight.amenities) || 0,
            reviews: Number(weight.reviews) || 0,
        };
    }

    score(residence) {
        if (!residence) {
            return -Infinity;
        }

        const totalAccommodationCost =
            this.getAccommodationCost(residence);

        if (totalAccommodationCost === null) {
            return -Infinity;
        }

        const priceScore =
            this._calculatePriceScore(totalAccommodationCost);

        const ratingScore =
            this._calculateRatingScore(residence);

        const amenityScore =
            this._calculateAmenityScore(residence);

        const reviewScore =
            this._calculateReviewScore(residence);

        return (
            this.weight.price * priceScore +
            this.weight.rating * ratingScore +
            this.weight.amenities * amenityScore +
            this.weight.reviews * reviewScore
        );
    }

    getAccommodationCost(residence) {
        if (!residence) {
            return null;
        }

        const rooms =
            RoomCapacityPolicy.getRequiredRooms(
                this.numberOfPeople
            );

        if (rooms <= 0) {
            return null;
        }

        const nights = Number(this.nights) || 0;

        if (nights <= 0) {
            return null;
        }

        return residence.getEstimatedAccommodationCost({
            nights,
            rooms,
        });
    }

    selectBest(residencies) {
        if (!Array.isArray(residencies) || residencies.length === 0) {
            return null;
        }

        let bestResidence = null;
        let bestScore = -Infinity;

        for (const residence of residencies) {
            const score = this.score(residence);

            if (score > bestScore) {
                bestScore = score;
                bestResidence = residence;
            }
        }

        if (!bestResidence) {
            return null;
        }

        return {
            residence: bestResidence,
            score: bestScore,
        };
    }

    _calculatePriceScore(totalAccommodationCost) {
        if (this.maxBudget <= 0) {
            return 1;
        }

        const cost = Number(totalAccommodationCost) || 0;

        if (cost <= this.maxBudget) {
            return 1 - (cost / this.maxBudget) * 0.5;
        }

        const overBudgetRatio =
            (cost - this.maxBudget) / this.maxBudget;

        return Math.max(
            0,
            0.5 - overBudgetRatio
        );
    }

    _calculateRatingScore(residence) {
        const rating = Number(residence.rating) || 0;

        if (rating <= this.minRating) {
            return 0;
        }

        const ratingRange =
            Math.max(5 - this.minRating, 1);

        return Math.min(
            1,
            (rating - this.minRating) / ratingRange
        );
    }

    _calculateAmenityScore(residence) {
        if (this.preferredAmenities.length === 0) {
            return 0;
        }

        const matchingAmenities =
            this.preferredAmenities.filter(
                amenity => residence.hasAmenity(amenity)
            ).length;

        return (
            matchingAmenities /
            this.preferredAmenities.length
        );
    }

    _calculateReviewScore(residence) {
        const numberOfReviews =
            Number(residence.numberOfReviews) || 0;

        return (
            Math.log1p(numberOfReviews) /
            Math.log1p(1000)
        );
    }
}

module.exports = WeightedResidenceScorer;