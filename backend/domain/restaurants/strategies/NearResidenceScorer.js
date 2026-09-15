const RestaurantScorer =
    require('./RestaurantScorer');

const Location =
    require('../../locations/Location');

class NearResidenceScorer
    extends RestaurantScorer {

    score(restaurant, residence) {
        if (!restaurant || !residence) {
            return -Infinity;
        }

        const distance =
            Location.distanceBetween(
                restaurant,
                residence
            );

        let score = 0;

        score +=
            (1 / Math.max(distance, 0.01)) *
            10;

        score +=
            (restaurant.numberOfReviews || 0) /
            10;

        score +=
            (restaurant.rating || 0) *
            10;

        return score;
    }
}

module.exports =
    NearResidenceScorer;