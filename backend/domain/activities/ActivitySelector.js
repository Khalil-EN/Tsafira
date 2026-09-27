const ActivityEligibilityPolicy = require('./ActivityEligibilityPolicy');
const SoftBudgetScore = require('../itineraries/budget/SoftBudgetScore');

class ActivitySelector {
    constructor({
        scorer,
        grouper,
        days,
        numberOfPeople,
        activityBudget,
        eligibilityPolicy,
        maxActivitiesPerGroup = 3,
    }) {
        this.scorer = scorer;
        this.grouper = grouper;
        this.days = Number(days) || 0;
        this.numberOfPeople = Number(numberOfPeople) || 1;
        this.activityBudget = Number(activityBudget) || 0;
        this.maxActivitiesPerGroup = Math.max(1, Number(maxActivitiesPerGroup) || 3);

        this.eligibilityPolicy =
            eligibilityPolicy ||
            new ActivityEligibilityPolicy({numberOfPeople: this.numberOfPeople,});
    }

    select(activities) {
        const warnings = [];

        if (!Array.isArray(activities) || activities.length === 0) {
            warnings.push('No activities are available.');

            return {
                groups: [],
                warnings,
            };
        }

        const eligibleActivities = activities.filter(activity =>
            this.eligibilityPolicy.isEligible(activity)
        );

        if (eligibleActivities.length === 0) {
            warnings.push('No valid activities are available.');

            return {
                groups: [],
                warnings,
            };
        }

        const scoredActivities = this._scoreActivities(eligibleActivities);

        const requestedGroupCount = this.days * 2;

        const groupBudget =
            requestedGroupCount > 0
                ? this.activityBudget / requestedGroupCount
                : this.activityBudget;

        const groups = this.grouper.group(
            scoredActivities,
            {
                groupBudget,
            }
        );

        const selectedGroups = groups.slice(0, requestedGroupCount);

        if (selectedGroups.length < requestedGroupCount) {
            warnings.push(
                `Only ${selectedGroups.length} of ` +
                `${requestedGroupCount} activity groups ` +
                `could be created.`
            );
        }

        return {
            groups: selectedGroups,
            warnings,
        };
    }

    _scoreActivities(activities) {
        const scored = this.scorer.scoreAll(activities);

        return scored.map(item => {
            const estimatedCost =
                item.activity.getEstimatedCost(
                    this.numberOfPeople
                );

            const originalScore = Number(item.score) || 0;

            const budgetScore = SoftBudgetScore.calculate(
                estimatedCost,
                this._getIndividualActivityBudget()
            );

            const score = originalScore + budgetScore * 10;

            return {
                ...item,
                originalScore,
                budgetScore,
                score,
                estimatedCost,
                numberOfPeople: this.numberOfPeople,
            };
        });
    }

    _getIndividualActivityBudget() {
        const activityCount = this.days * 2;

        if (activityCount <= 0) {
            return this.activityBudget;
        }

        return this.activityBudget / activityCount;
    }
}

module.exports = ActivitySelector;