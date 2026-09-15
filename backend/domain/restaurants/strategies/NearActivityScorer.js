const RestaurantScorer =
    require('./RestaurantScorer');

const Location =
    require('../../locations/Location');

class NearActivityScorer
    extends RestaurantScorer {

    constructor({
        cuisineTags = [],
        facilities = [],
    } = {}) {
        super();

        this.cuisineTags =
            cuisineTags;

        this.facilities =
            facilities;
    }

    score(restaurant, activity) {
        if (!restaurant || !activity) {
            return -Infinity;
        }

        let score =
            this._baseScore(restaurant);

        const distance =
            Location.distanceBetween(
                restaurant,
                activity
            );

        if (distance < 1) {
            score += 20;
        } else if (distance < 5) {
            score += 10;
        } else if (distance < 10) {
            score += 5;
        }

        return score;
    }

    _baseScore(restaurant) {
        let score = 0;

        for (const tag of this.cuisineTags) {
            if (restaurant.hasTag(tag)) {
                score += 10;
            }
        }

        for (
            const facility of this.facilities
        ) {
            if (
                restaurant.hasFacility(
                    facility
                )
            ) {
                score += 5;
            }
        }

        score +=
            (restaurant.numberOfReviews || 0) *
            0.01;

        score +=
            (restaurant.rating || 0) *
            10;

        return score;
    }
}

module.exports =
    NearActivityScorer;