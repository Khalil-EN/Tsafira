class BudgetSummary {
    constructor({
        totalBudget = 0,
        accommodationBudget = 0,
        foodBudget = 0,
        activityBudget = 0,
        transportBudget = 0,
        mealBudgets = {},
    } = {}) {
        this.totalBudget = Number(totalBudget) || 0;

        this.allocated = {
            accommodation: Number(accommodationBudget) || 0,
            food: Number(foodBudget) || 0,
            activities: Number(activityBudget) || 0,
            transport: Number(transportBudget) || 0,
        };

        this.mealBudgets = {
            breakfast: Number(mealBudgets.breakfast) || 0,
            lunch: Number(mealBudgets.lunch) || 0,
            dinner: Number(mealBudgets.dinner) || 0,
        };

        this.spent = {
            accommodation: 0,
            food: 0,
            activities: 0,
            transport: 0,
        };

        this.warnings = [];
    }

    addAccommodationCost(amount) {
        this.spent.accommodation += Number(amount) || 0;
    }

    addFoodCost(amount) {
        this.spent.food += Number(amount) || 0;
    }

    addActivityCost(amount) {
        this.spent.activities += Number(amount) || 0;
    }

    addTransportCost(amount) {
        this.spent.transport += Number(amount) || 0;
    }

    addWarning(message) {
        if (!message) {
            return;
        }

        if (!this.warnings.includes(message)) {
            this.warnings.push(message);
        }
    }

    getTotalSpent() {
        return (
            this.spent.accommodation +
            this.spent.food +
            this.spent.activities +
            this.spent.transport
        );
    }

    getRemainingBudget() {
        return this.totalBudget - this.getTotalSpent();
    }

    getRemaining(category) {
        if (!Object.prototype.hasOwnProperty.call(this.allocated, category)) {
            return 0;
        }

        return (
            this.allocated[category] -
            this.spent[category]
        );
    }

    getOverBudgetAmount() {
        return Math.max(
            0,
            this.getTotalSpent() - this.totalBudget
        );
    }

    getCategoryOverBudget(category) {
        if (!Object.prototype.hasOwnProperty.call(this.allocated, category)) {
            return 0;
        }

        return Math.max(
            0,
            this.spent[category] -
            this.allocated[category]
        );
    }

    isWithinBudget() {
        return this.getTotalSpent() <= this.totalBudget;
    }

    finalizeWarnings() {
        const overBudget = this.getOverBudgetAmount();

        if (overBudget > 0) {
            this.addWarning(
                `The itinerary exceeds your budget by ${overBudget.toFixed(2)} DH.`
            );
        }

        const accommodationOver =
            this.getCategoryOverBudget('accommodation');

        if (accommodationOver > 0) {
            this.addWarning(
                `Accommodation exceeds its allocated budget by ${accommodationOver.toFixed(2)} DH.`
            );
        }

        const foodOver =
            this.getCategoryOverBudget('food');

        if (foodOver > 0) {
            this.addWarning(
                `Food exceeds its allocated budget by ${foodOver.toFixed(2)} DH.`
            );
        }

        const activitiesOver =
            this.getCategoryOverBudget('activities');

        if (activitiesOver > 0) {
            this.addWarning(
                `Activities exceed their allocated budget by ${activitiesOver.toFixed(2)} DH.`
            );
        }

        const transportOver =
            this.getCategoryOverBudget('transport');

        if (transportOver > 0) {
            this.addWarning(
                `Transport exceeds its allocated budget by ${transportOver.toFixed(2)} DH.`
            );
        }

        return this;
    }

    toJSON() {
        return {
            totalBudget: this.totalBudget,

            allocated: {
                accommodation: this.allocated.accommodation,
                food: this.allocated.food,
                activities: this.allocated.activities,
                transport: this.allocated.transport,
            },

            mealBudgets: {
                breakfast: this.mealBudgets.breakfast,
                lunch: this.mealBudgets.lunch,
                dinner: this.mealBudgets.dinner,
            },

            spent: {
                accommodation: this.spent.accommodation,
                food: this.spent.food,
                activities: this.spent.activities,
                transport: this.spent.transport,
            },

            totalSpent: this.getTotalSpent(),

            remainingBudget: this.getRemainingBudget(),

            overBudget: this.getOverBudgetAmount(),

            withinBudget: this.isWithinBudget(),

            warnings: [...this.warnings],
        };
    }
}

module.exports = BudgetSummary;