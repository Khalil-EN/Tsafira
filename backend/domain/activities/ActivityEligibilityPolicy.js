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

        /*
         * maxCost is intentionally NOT used as a hard constraint.
         *
         * Budget is handled by ActivitySelector through soft
         * budget scoring.
         */
        return true;
    }
}

module.exports = ActivityEligibilityPolicy;