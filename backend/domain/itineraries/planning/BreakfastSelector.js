const Location = require('../../locations/location');
const SoftBudgetScore = require('../budget/SoftBudgetScore');

const BREAKFAST_RADIUS_KM = 10;

class BreakfastSelector {
    constructor({scorer, residency, days, numberOfPeople, dailyBudget}) {
        this.scorer = scorer;
        this.residency = residency;
        this.days = Number(days) || 1;
        this.numberOfPeople = Number(numberOfPeople) || 1;
        this.dailyBudget = Number(dailyBudget) || 0;
    }

    select(restaurants) {
        if (!this._canSelect(restaurants)) {
            return [];
        }

        const candidates = restaurants
            .filter(restaurant => this._isBreakfastRestaurant(restaurant))
            .filter(restaurant => this._hasValidLocation(restaurant))
            .map(restaurant => this._buildCandidate(restaurant))
            .filter(Boolean)
            .sort((a, b) => b.score - a.score);

        if (candidates.length === 0) {
            return [];
        }

        return this._selectForDays(candidates);
    }

    _canSelect(restaurants) {
        return (
            this.residency &&
            Array.isArray(restaurants) &&
            restaurants.length > 0 &&
            this.residency.latitude != null &&
            this.residency.longitude != null
        );
    }

    _buildCandidate(restaurant) {
        const distance = Location.distanceBetween(restaurant, this.residency);

        if (!Number.isFinite(distance) || distance > BREAKFAST_RADIUS_KM) {
            return null;
        }

        const estimatedCost = this._getMealCost(restaurant);

        if (estimatedCost === null) {
            return null;
        }

        const restaurantScore = this._getRestaurantScore(restaurant);
        const budgetScore = SoftBudgetScore.calculate(estimatedCost, this.dailyBudget);
        const proximityScore = this._calculateProximityScore(distance);

        const finalScore = restaurantScore + proximityScore * 10 + budgetScore * 10;

        return {
            restaurant,
            score: finalScore,
            restaurantScore,
            proximityScore,
            budgetScore,
            estimatedCost,
            distance,
        };
    }

    _selectForDays(candidates) {
        const selected = [];
        const chosen = new Set();

        for (let day = 1; day <= this.days; day++) {
            const candidate = candidates.find(item => {
                const key = this._getRestaurantKey(item.restaurant);
                return !chosen.has(key);
            });

            const fallback = candidate ?? candidates[0];

            if (!fallback) {
                break;
            }

            const key = this._getRestaurantKey(fallback.restaurant);
            chosen.add(key);
            selected.push({day, restaurant: fallback.restaurant});
        }

        return selected;
    }

    _isBreakfastRestaurant(restaurant) {
        if (!restaurant) {
            return false;
        }

        if (Array.isArray(restaurant.meals)) {
            return restaurant.meals.some(meal => String(meal).trim().toLowerCase() === 'breakfast');
        }

        if (typeof restaurant.servesMeal === 'function') {
            return restaurant.servesMeal('breakfast');
        }

        return false;
    }

    _hasValidLocation(restaurant) {
        return (
            restaurant &&
            restaurant.latitude != null &&
            restaurant.longitude != null
        );
    }

    _getMealCost(restaurant) {
        if (!restaurant || typeof restaurant.getEstimatedMealCost !== 'function') {
            return null;
        }

        const cost = restaurant.getEstimatedMealCost(this.numberOfPeople);
        if (cost === null || cost === undefined || !Number.isFinite(Number(cost))) {
            return null;
        }

        return Number(cost);
    }

    _getRestaurantScore(restaurant) {
        if (!this.scorer || typeof this.scorer.score !== 'function') {
            return 0;
        }

        const score = this.scorer.score(restaurant, this.residency);
        return Number(score) || 0;
    }

    _calculateProximityScore(distance) {
        if (!Number.isFinite(distance)) {
            return 0;
        }

        if (distance <= 0) {
            return 1;
        }

        if (distance >= BREAKFAST_RADIUS_KM) {
            return 0;
        }

        return 1 - distance / BREAKFAST_RADIUS_KM;
    }

    _getRestaurantKey(restaurant) {
        return restaurant?.id ?? restaurant?.name;
    }
}

module.exports = BreakfastSelector;