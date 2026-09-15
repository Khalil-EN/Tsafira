class RestaurantEligibilityPolicy {
    constructor({ numberOfPeople }) {
        this.numberOfPeople = numberOfPeople;
    }

    isEligible(
        restaurant,
        { meal, maxCost } = {}
    ) {
        if (!restaurant) {
            return false;
        }

        if (!restaurant.servesMeal(meal)) {
            return false;
        }

        const estimatedCost =
            restaurant.getEstimatedMealCost(
                this.numberOfPeople
            );

        if (estimatedCost === null) {
            return false;
        }

        /*
         * maxCost is intentionally NOT used as a hard constraint.
         *
         * RestaurantAssigner applies soft budget scoring instead.
         */
        return true;
    }
}

module.exports = RestaurantEligibilityPolicy;