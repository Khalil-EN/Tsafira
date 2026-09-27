class ActivityEligibilityPolicy {
    constructor({ numberOfPeople }) {
        this.numberOfPeople = numberOfPeople;
    }

    isEligible(activity, { maxCost } = {}) {
        if (!activity) {
            return false;
        }

        const estimatedCost =
            activity.getEstimatedCost(this.numberOfPeople);

        if (estimatedCost === null) {
            return false;
        }

        return true;
    }
}

module.exports = ActivityEligibilityPolicy;