const BudgetSummary = require('../budget/BudgetSummary');
const ActivitySelector = require('../../activities/ActivitySelector');
const RestaurantAssigner = require('../../restaurants/RestaurantAssigner');
const BreakfastSelector = require('./BreakfastSelector');
const DayPlanBuilder = require('./DayPlanBuilder');

class ItineraryPlanner {
    constructor({
        activityScorer,
        activityGrouper,
        activityEligibilityPolicy,

        restaurantScorer,
        restaurantEligibilityPolicy,

        breakfastScorer,
        residenceScorer,

        days = 1,
        meals = [],
        numberOfPeople = 1,

        activityBudget = 0,
        mealBudgets = {},
        accommodationBudget = 0,
    } = {}) {
        this.activityScorer = activityScorer;
        this.activityGrouper = activityGrouper;
        this.activityEligibilityPolicy = activityEligibilityPolicy;

        this.restaurantScorer = restaurantScorer;
        this.restaurantEligibilityPolicy = restaurantEligibilityPolicy;

        this.breakfastScorer = breakfastScorer;
        this.residenceScorer = residenceScorer;

        this.days = Number(days) || 1;
        this.meals = Array.isArray(meals) ? meals : [];
        this.numberOfPeople = Number(numberOfPeople) || 1;

        this.activityBudget = Number(activityBudget) || 0;

        this.mealBudgets = {
            breakfast: Number(mealBudgets.breakfast) || 0,
            lunch: Number(mealBudgets.lunch) || 0,
            dinner: Number(mealBudgets.dinner) || 0,
        };

        this.accommodationBudget = Number(accommodationBudget) || 0;
    }

    plan(activities, restaurants, residencies, nightActivities = [], {totalBudget = 0, foodBudget = 0,
                                                                        activityBudget = this.activityBudget,
                                                                        transportBudget = 0,
                                                                     } = {}
    ) {
        const budgetSummary = new BudgetSummary({
            totalBudget,
            accommodationBudget: this.accommodationBudget,
            foodBudget,
            activityBudget,
            transportBudget,
            mealBudgets: this.mealBudgets,
        });


        const residenceResult = this.residenceScorer?.selectBest(residencies);

        const residency = residenceResult?.residence ?? null;

        if (residency) {
            const accommodationCost = this._getAccommodationCost(residency);

            if (accommodationCost !== null) {
                budgetSummary.addAccommodationCost(accommodationCost);
            }
        } else {
            this._addResidenceDiagnosticWarning(budgetSummary);
        }

        const activitySelector =
            new ActivitySelector({
                scorer: this.activityScorer,
                grouper: this.activityGrouper,
                days: this.days,
                numberOfPeople: this.numberOfPeople,
                activityBudget,
                eligibilityPolicy: this.activityEligibilityPolicy,
            });

        const {
            groups: selectedActivityGroups,
            warnings: activityWarnings,
        } = activitySelector.select(activities);

        for (const warning of activityWarnings) {
            budgetSummary.addWarning(warning);
        }

        const days = DayPlanBuilder.build(selectedActivityGroups,this.days);

        const restaurantAssigner =
          new RestaurantAssigner({
              scorer: this.restaurantScorer,
              eligibilityPolicy:
                  this.restaurantEligibilityPolicy,
              meals: this.meals,
              mealBudgets: this.mealBudgets,
              numberOfPeople: this.numberOfPeople,
          });

        const daysWithRestaurants = restaurantAssigner.assign(days, restaurants);

        const breakfastSelector =
            new BreakfastSelector({
                scorer: this.breakfastScorer,
                residency: residency,
                days: this.days,
                dailyBudget: this.mealBudgets.breakfast,
                numberOfPeople: this.numberOfPeople,
            });

        const breakfastSlots = this.meals
                .map(meal => String(meal).toLowerCase())
                .includes('breakfast')
                ? breakfastSelector.select(restaurants)
                : [];

        for (const day of daysWithRestaurants) {
            for (const activity of day.morningActivities ?? []) {
                const cost = this._getActivityCost(activity);

                if (cost !== null) {
                    budgetSummary.addActivityCost(cost);
                }
            }

            for (const activity of day.afternoonActivities ?? []
            ) {
                const cost = this._getActivityCost(activity);

                if (cost !== null) {
                    budgetSummary.addActivityCost(cost);
                }
            }
        }

        for (const day of daysWithRestaurants) {
            if (day.lunch) {
                const cost = this._getRestaurantCost(day.lunch);

                if (cost !== null) {
                    budgetSummary.addFoodCost(cost);
                }
            }

            if (day.dinner) {
                const cost = this._getRestaurantCost(day.dinner);

                if (cost !== null) {
                    budgetSummary.addFoodCost(cost);
                }
            }
        }

        for (const slot of breakfastSlots) {
            if (!slot?.restaurant) {
                continue;
            }

            const cost = this._getRestaurantCost(slot.restaurant);

            if (cost !== null) {
                budgetSummary.addFoodCost(cost);
            }
        }

        budgetSummary.finalizeWarnings();

        return {
          residency,
          days: daysWithRestaurants,
          breakfastSlots,
          nightActivities,
          meals: this.meals,
          budget: budgetSummary,
          warnings: [...budgetSummary.warnings],
      };
    }


    _getActivityCost(activity) {
        if (!activity) {
            return null;
        }

        if (typeof activity.getEstimatedCost !== 'function') {
            return null;
        }

        const cost = activity.getEstimatedCost(this.numberOfPeople);

        if (!Number.isFinite(Number(cost))) {
            return null;
        }

        return Number(cost);
    }

    _getRestaurantCost(restaurant) {
        if (!restaurant) {
            return null;
        }

        if (typeof restaurant.getEstimatedMealCost !== 'function') {
            return null;
        }

        const cost = restaurant.getEstimatedMealCost(this.numberOfPeople);

        if (!Number.isFinite(Number(cost))) {
            return null;
        }

        return Number(cost);
    }

    _getAccommodationCost(residency) {
        if (!residency) {
            return null;
        }

        if (!this.residenceScorer || typeof this.residenceScorer.getAccommodationCost !== 'function') {
            return null;
        }

        const cost = this.residenceScorer.getAccommodationCost(residency);

        if (!Number.isFinite(Number(cost))) {
            return null;
        }

        return Number(cost);
    }

    _addResidenceDiagnosticWarning(budgetSummary) {
        if (!budgetSummary) {
            return;
        }

        if (!this.residenceScorer) {
            budgetSummary.addWarning('No residence scorer is configured.');

            return;
        }

        budgetSummary.addWarning('No suitable residence was found.');
    }
}

module.exports = ItineraryPlanner;