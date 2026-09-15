class BudgetAllocation {
    constructor({
        totalBudget,
        accommodationPercentage = 0.40,
        foodPercentage = 0.30,
        activitiesPercentage = 0.20,
        transportPercentage = 0.10,
    }) {
        this.totalBudget = totalBudget;

        this.accommodationPercentage =
            accommodationPercentage;

        this.foodPercentage =
            foodPercentage;

        this.activitiesPercentage =
            activitiesPercentage;

        this.transportPercentage =
            transportPercentage;

        this._validatePercentages();
    }

    _validatePercentages() {
        const total =
            this.accommodationPercentage +
            this.foodPercentage +
            this.activitiesPercentage +
            this.transportPercentage;

        if (Math.abs(total - 1) > 0.0001) {
            throw new Error(
                'Budget allocation percentages must equal 1.'
            );
        }
    }

    getAccommodationBudget() {
        return (
            this.totalBudget *
            this.accommodationPercentage
        );
    }

    getFoodBudget() {
        return (
            this.totalBudget *
            this.foodPercentage
        );
    }

    getActivitiesBudget() {
        return (
            this.totalBudget *
            this.activitiesPercentage
        );
    }

    getTransportBudget() {
        return (
            this.totalBudget *
            this.transportPercentage
        );
    }

    getFoodBudgetPerDay(days) {
        if (!Number.isFinite(days) || days <= 0) {
            return 0;
        }

        return this.getFoodBudget() / days;
    }

    getActivityBudgetPerDay(days) {
        if (!Number.isFinite(days) || days <= 0) {
            return 0;
        }

        return this.getActivitiesBudget() / days;
    }
}

module.exports = BudgetAllocation;