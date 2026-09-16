const BudgetAllocationPolicy =
    require('../budget/BudgetAllocationPolicy');

const MealBudgetPolicy =
    require('../budget/MealBudgetPolicy');

class ScoringConfig {
    constructor({
        maxBudget,

        accommodationBudget,

        foodBudget,

        activityBudget,

        transportBudget,

        activityBudgetPerDay,

        mealBudgets,

        facilities,

        minRating = 4,

        preferredAmenities = [
            'wifi',
            'breakfast',
            'air conditioning',
        ],

        weight = {
            price: 0.4,
            rating: 0.3,
            amenities: 0.1,
        },
    }) {
        this.maxBudget =
            Number(maxBudget) || 0;

        this.accommodationBudget =
            Number(
                accommodationBudget
            ) || 0;

        this.foodBudget =
            Number(foodBudget) || 0;

        this.activityBudget =
            Number(activityBudget) || 0;

        this.transportBudget =
            Number(transportBudget) || 0;

        this.activityBudgetPerDay =
            Number(
                activityBudgetPerDay
            ) || 0;

        this.mealBudgets =
            mealBudgets || {
                breakfast: 0,
                lunch: 0,
                dinner: 0,
            };

        this.facilities =
            Array.isArray(facilities)
                ? facilities
                : [];

        this.minRating =
            minRating;

        this.preferredAmenities =
            preferredAmenities;

        this.weight =
            weight;
    }

    static fromRequest(request) {
        const totalBudget =
            Number(request.budget) || 0;

        const days =
            Number(request.days) || 1;

        const allocation =
            BudgetAllocationPolicy.allocate(
                totalBudget
            );

        const mealBudgets =
            MealBudgetPolicy.allocate(
                allocation.food,
                days,
                request.meals
            );

        const activityBudgetPerDay =
            days > 0
                ? allocation.activities /
                  days
                : 0;

        return new ScoringConfig({
            maxBudget:
                totalBudget,

            accommodationBudget:
                allocation.accommodation,

            foodBudget:
                allocation.food,

            activityBudget:
                allocation.activities,

            transportBudget:
                allocation.transport,

            activityBudgetPerDay,

            mealBudgets,

            facilities: [
                ...request.paymentPreferences,
                ...request.dietaryPreferences,
            ],
        });
    }
}

module.exports =
    ScoringConfig;