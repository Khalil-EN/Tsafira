const Location =
    require('../locations/Location');

const SoftBudgetScore =
    require('./SoftBudgetScore');

const BREAKFAST_RADIUS_KM = 10;

class BreakfastSelector {
    constructor({
        scorer,
        residency,
        days,
        numberOfPeople,
        dailyBudget,
    }) {
        this.scorer =
            scorer;

        this.residency =
            residency;

        this.days =
            Number(days) || 1;

        this.numberOfPeople =
            Number(numberOfPeople) || 1;

        this.dailyBudget =
            Number(dailyBudget) || 0;
    }

    select(restaurants) {
        if (
            !this.residency ||
            !Array.isArray(restaurants) ||
            restaurants.length === 0
        ) {
            return [];
        }

        if (
            this.residency.latitude == null ||
            this.residency.longitude == null
        ) {
            return [];
        }

        /*
         * --------------------------------------------------
         * 1. Find valid breakfast restaurants
         * --------------------------------------------------
         *
         * IMPORTANT:
         * Budget is NOT used as an eligibility condition.
         *
         * A restaurant can be more expensive than the
         * breakfast budget and still be selected if it is
         * otherwise a good option.
         */
        const candidates =
            restaurants
                .filter(restaurant =>
                    this._isBreakfastRestaurant(
                        restaurant
                    )
                )
                .filter(restaurant =>
                    this._hasValidLocation(
                        restaurant
                    )
                )
                .map(restaurant => {
                    const distance =
                        Location.distanceBetween(
                            restaurant,
                            this.residency
                        );

                    if (
                        !Number.isFinite(distance) ||
                        distance >
                            BREAKFAST_RADIUS_KM
                    ) {
                        return null;
                    }

                    const estimatedCost =
                        this._getMealCost(
                            restaurant
                        );

                    if (
                        estimatedCost === null
                    ) {
                        return null;
                    }

                    /*
                     * Restaurant quality / relevance.
                     */
                    const restaurantScore =
                        this._getRestaurantScore(
                            restaurant
                        );

                    /*
                     * Soft budget score.
                     *
                     * This affects ranking but NEVER
                     * eliminates the restaurant.
                     */
                    const budgetScore =
                        SoftBudgetScore.calculate(
                            estimatedCost,
                            this.dailyBudget
                        );

                    /*
                     * Proximity score.
                     *
                     * Closer restaurants are preferred.
                     */
                    const proximityScore =
                        this._calculateProximityScore(
                            distance
                        );

                    /*
                     * Final score:
                     *
                     * - restaurant quality
                     * - proximity
                     * - affordability
                     *
                     * Budget is therefore a preference,
                     * not a hard constraint.
                     */
                    const finalScore =
                        restaurantScore +
                        proximityScore * 10 +
                        budgetScore * 10;

                    return {
                        restaurant,
                        score: finalScore,
                        restaurantScore,
                        proximityScore,
                        budgetScore,
                        estimatedCost,
                        distance,
                    };
                })
                .filter(Boolean)
                .sort(
                    (a, b) =>
                        b.score - a.score
                );

        if (candidates.length === 0) {
            return [];
        }

        /*
         * --------------------------------------------------
         * 2. Select one breakfast restaurant per day
         * --------------------------------------------------
         *
         * Avoid using the same restaurant repeatedly
         * when enough breakfast restaurants exist.
         */
        const selected = [];

        const chosen = new Set();

        for (
            let day = 1;
            day <= this.days;
            day++
        ) {
            const candidate =
                candidates.find(item => {
                    const key =
                        this._getRestaurantKey(
                            item.restaurant
                        );

                    return !chosen.has(key);
                });

            /*
             * If we have fewer unique breakfast
             * restaurants than days, reuse the best
             * restaurant rather than returning no
             * breakfast.
             */
            const fallback =
                candidate ??
                candidates[0];

            if (!fallback) {
                break;
            }

            const key =
                this._getRestaurantKey(
                    fallback.restaurant
                );

            chosen.add(key);

            selected.push({
                day,
                restaurant:
                    fallback.restaurant,
            });
        }

        return selected;
    }

    /*
     * ------------------------------------------------------
     * BREAKFAST ELIGIBILITY
     * ------------------------------------------------------
     *
     * The restaurant's meals field is the primary source.
     *
     * Example:
     *
     * meals: ['breakfast', 'brunch']
     *
     * -> valid breakfast restaurant.
     */
    _isBreakfastRestaurant(restaurant) {
        if (!restaurant) {
            return false;
        }

        if (
            Array.isArray(
                restaurant.meals
            )
        ) {
            return restaurant.meals.some(
                meal =>
                    String(meal)
                        .trim()
                        .toLowerCase() ===
                    'breakfast'
            );
        }

        /*
         * Fallback for domain models that expose
         * servesMeal() instead of a public meals array.
         */
        if (
            typeof restaurant.servesMeal ===
            'function'
        ) {
            return restaurant.servesMeal(
                'breakfast'
            );
        }

        return false;
    }

    /*
     * ------------------------------------------------------
     * LOCATION VALIDATION
     * ------------------------------------------------------
     */
    _hasValidLocation(restaurant) {
        return (
            restaurant &&
            restaurant.latitude != null &&
            restaurant.longitude != null
        );
    }

    /*
     * ------------------------------------------------------
     * MEAL COST
     * ------------------------------------------------------
     *
     * Uses the restaurant domain model rather than
     * trying to calculate the price here.
     */
    _getMealCost(restaurant) {
        if (
            !restaurant ||
            typeof restaurant
                .getEstimatedMealCost !==
                'function'
        ) {
            return null;
        }

        const cost =
            restaurant.getEstimatedMealCost(
                this.numberOfPeople
            );

        if (
            cost === null ||
            cost === undefined ||
            !Number.isFinite(
                Number(cost)
            )
        ) {
            return null;
        }

        return Number(cost);
    }

    /*
     * ------------------------------------------------------
     * RESTAURANT SCORE
     * ------------------------------------------------------
     */
    _getRestaurantScore(restaurant) {
        if (
            !this.scorer ||
            typeof this.scorer.score !==
                'function'
        ) {
            return 0;
        }

        const score =
            this.scorer.score(
                restaurant,
                this.residency
            );

        return Number(score) || 0;
    }

    /*
     * ------------------------------------------------------
     * PROXIMITY SCORE
     * ------------------------------------------------------
     *
     * 0 km  -> 1
     * 10 km -> 0
     *
     * This keeps proximity as a preference rather
     * than another hard constraint.
     */
    _calculateProximityScore(distance) {
        if (
            !Number.isFinite(distance)
        ) {
            return 0;
        }

        if (
            distance <= 0
        ) {
            return 1;
        }

        if (
            distance >=
            BREAKFAST_RADIUS_KM
        ) {
            return 0;
        }

        return (
            1 -
            distance /
                BREAKFAST_RADIUS_KM
        );
    }

    /*
     * ------------------------------------------------------
     * RESTAURANT KEY
     * ------------------------------------------------------
     */
    _getRestaurantKey(restaurant) {
        return (
            restaurant?.id ??
            restaurant?.name
        );
    }
}

module.exports =
    BreakfastSelector;