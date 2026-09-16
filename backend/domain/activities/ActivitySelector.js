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
        this.maxActivitiesPerGroup =
            Math.max(1, Number(maxActivitiesPerGroup) || 3);

        this.eligibilityPolicy =
            eligibilityPolicy ||
            new ActivityEligibilityPolicy({
                numberOfPeople: this.numberOfPeople,
            });
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

        /*
         * Budget is NOT an eligibility constraint.
         *
         * We only reject activities that are genuinely invalid
         * or whose cost cannot be estimated.
         */
        const eligibleActivities = activities.filter(activity =>
            this.eligibilityPolicy.isEligible(activity)
        );

        if (eligibleActivities.length === 0) {
            warnings.push(
                'No valid activities are available.'
            );

            return {
                groups: [],
                warnings,
            };
        }

        const scoredActivities = this._scoreActivities(
            eligibleActivities
        );

        /*
         * There are two activity groups per day:
         *
         * Day 1: morning + afternoon
         * Day 2: morning + afternoon
         * ...
         */
        const requestedGroupCount = this.days * 2;

        /*
         * The total activity budget is distributed as a soft
         * target across the activity slots.
         */
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

        const selectedGroups = groups.slice(
            0,
            requestedGroupCount
        );

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

        /*
         * Preserve the original quality score.
         *
         * ProximityGrouper uses this to determine whether two
         * activities are genuinely comparable in quality.
         *
         * The final score can include a soft budget preference.
         */
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

            /*
             * Budget is deliberately a secondary factor.
             * It should influence selection without destroying
             * the activity's quality/relevance score.
             */
            const score =
                originalScore +
                budgetScore * 10;

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