const Location = require('../../locations/location');

class RestaurantAssigner {
    constructor({
        scorer,
        eligibilityPolicy,
        meals = [],
        mealBudgets = {},
        numberOfPeople = 1,
        maxRestaurantDistanceKm = 5,
    } = {}) {
        this.scorer = scorer;
        this.eligibilityPolicy = eligibilityPolicy;

        this.meals = new Set(meals.map(meal => meal.toLowerCase()));

        this.mealBudgets = {
            breakfast: Number(mealBudgets.breakfast) || 0,
            lunch: Number(mealBudgets.lunch) || 0,
            dinner: Number(mealBudgets.dinner) || 0,
        };

        this.numberOfPeople = Number(numberOfPeople) || 1;
        this.maxRestaurantDistanceKm = Number(maxRestaurantDistanceKm) || 5;
    }

    assign(days, restaurants) {
        if (!Array.isArray(days) || !Array.isArray(restaurants)) {
            return [];
        }

        const chosen = new Set();

        return days.map(day => {const result = {...day, lunch: null, dinner: null,};

            if (this.meals.has('lunch')) {
                result.lunch = this._selectRestaurant({
                    restaurants,
                    meal: 'lunch',
                    budget: this.mealBudgets.lunch,
                    activities: day.morningActivities ?? this._toActivityArray(day.morningActivity),
                    chosen,
                });
            }

            if (this.meals.has('dinner')) {
                result.dinner = this._selectRestaurant({
                    restaurants,
                    meal: 'dinner',
                    budget: this.mealBudgets.dinner,
                    activities: day.afternoonActivities ?? this._toActivityArray(day.afternoonActivity),
                    chosen,
                });
            }

            return result;
        });
    }

    _selectRestaurant({restaurants, meal, budget, activities,chosen}) {
        if (!Array.isArray(activities) || activities.length === 0) {
            return null;
        }

        const candidates = restaurants.filter(restaurant => this._isEligible(restaurant, meal))
                                      .filter(restaurant => {const key = restaurant.id ?? restaurant.name;
                                                            return !chosen.has(key);})
                                      .map(restaurant => this._buildCandidate({restaurant, budget, activities}))
                                      .filter(Boolean)
                                      .sort((a, b) => this._compareCandidates(a, b));

        if (candidates.length === 0) {
            return null;
        }

        const selected = candidates[0].restaurant;
        const key = selected.id ?? selected.name;
        chosen.add(key);

        return selected;
    }

    _buildCandidate({restaurant, budget, activities}) {
        const mealCost = this._getMealCost(restaurant);

        const locationScore = this._calculateGroupLocationScore(restaurant, activities);

        const budgetScore = this._calculateBudgetScore(mealCost, budget);

        const qualityScore = this._calculateQualityScore(restaurant, activities);

        const score = qualityScore * 0.45 + locationScore * 0.35 + budgetScore * 0.20;

        return {
            restaurant,
            score,
            mealCost,
            locationScore,
            budgetScore,
            qualityScore,
            overBudget: this._getOverBudget(mealCost, budget),
        };
    }

    _compareCandidates(a, b) {
        const scoreDifference = b.score - a.score;

        if (Math.abs(scoreDifference) > 0.05) {
            return scoreDifference;
        }

        return a.overBudget - b.overBudget;
    }

    _isEligible(restaurant, meal) {
        if (!restaurant) {
            return false;
        }

        if (!restaurant.servesMeal || !restaurant.servesMeal(meal)) {
            return false;
        }

        const estimatedCost = this._getMealCost(restaurant);

        if (estimatedCost === null) {
            return false;
        }

        if (this.eligibilityPolicy) {
            return this.eligibilityPolicy.isEligible(restaurant,
                                                    {
                                                        meal,
                                                        maxCost: Infinity,
                                                    }
            );
        }

        return true;
    }

    _getMealCost(restaurant) {
        if (!restaurant || typeof restaurant.getEstimatedMealCost !== 'function') {
            return null;
        }

        const cost = restaurant.getEstimatedMealCost(this.numberOfPeople);

        if (!Number.isFinite(Number(cost))) {
            return null;
        }

        return Number(cost);
    }

    _calculateBudgetScore(cost, budget) {
        const numericCost = Number(cost) || 0;

        const numericBudget = Number(budget) || 0;

        if (numericBudget <= 0) {
            return 1;
        }

        if (numericCost <= numericBudget) {
            return 1 - (numericCost / numericBudget) * 0.5;
        }

        const overrun = (numericCost - numericBudget) / numericBudget;

        return Math.max(0, 0.5 - overrun);
    }

    _getOverBudget(cost, budget) {
        const numericCost = Number(cost) || 0;

        const numericBudget = Number(budget) || 0;

        if (numericBudget <= 0) {
            return 0;
        }

        return Math.max(0, numericCost - numericBudget);
    }

    _calculateGroupLocationScore(restaurant, activities) {
        if (!Array.isArray(activities) || activities.length === 0) {
            return 0;
        }

        const distances = activities.map(activity => this._getDistance(restaurant, activity))
                                    .filter(distance =>Number.isFinite(distance));

        if (distances.length === 0) {
            return 0;
        }

        const averageDistance = distances.reduce((sum, distance) => sum + distance, 0) / distances.length;

        if (averageDistance <= 0) {
            return 1;
        }

        if (averageDistance >= this.maxRestaurantDistanceKm) {
            return 0;
        }

        return (1 - averageDistance / this.maxRestaurantDistanceKm);
    }

    _getDistance(restaurant, activity) {
        if (!restaurant || !activity) {
            return Infinity;
        }

        try {
            return Location.distanceBetween(restaurant, activity);
        } catch (error) {
            return Infinity;
        }
    }

    _calculateQualityScore(restaurant,activities) {
        if (!this.scorer) {
            return 0;
        }

        if (typeof this.scorer.score !== 'function') {
            return 0;
        }

        if (!Array.isArray(activities) || activities.length === 0) {
            return 0;
        }

        const scores = activities.map(activity => {
                                        const score = this.scorer.score(restaurant,activity);
                                        return Number(score);})
                                 .filter(score => Number.isFinite(score));

        if (scores.length === 0) {
            return 0;
        }

        const average = scores.reduce((sum, score) => sum + score, 0) / scores.length;

        if (average >= 0 && average <= 1) {
            return average;
        }

        return 1 / (1 + Math.exp(-average / 10));
    }

    _toActivityArray(activity) {
        return activity ? [activity] : [];
    }
}

module.exports = RestaurantAssigner;