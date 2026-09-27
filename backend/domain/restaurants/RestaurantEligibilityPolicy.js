class RestaurantEligibilityPolicy {
    constructor({ numberOfPeople }) {
        this.numberOfPeople = numberOfPeople;
    }

    isEligible(restaurant, { meal, maxCost } = {}) {
        if (!restaurant) {
            return false;
        }

        if (!restaurant.servesMeal(meal)) {
            return false;
        }

        const estimatedCost = restaurant.getEstimatedMealCost(this.numberOfPeople);

        if (estimatedCost === null) {
            return false;
        }

        return true;
    }
}

module.exports = RestaurantEligibilityPolicy;