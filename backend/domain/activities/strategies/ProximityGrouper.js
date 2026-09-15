const ActivityGrouper = require('./ActivityGrouper');
const Location = require('../../locations/Location');

class ProximityGrouper extends ActivityGrouper {
    constructor({
        proximityKm = 5,
        scoreDifference = 10,
        maxActivitiesPerGroup = 2,
        groupBudget = 0,
    } = {}) {
        super();

        this.proximityKm = Number(proximityKm) || 5;
        this.scoreDifference = Number(scoreDifference) || 10;
        this.maxActivitiesPerGroup =
            Math.max(1, Number(maxActivitiesPerGroup) || 2);
        this.groupBudget = Number(groupBudget) || 0;
    }

    group(scoredActivities, { groupBudget = this.groupBudget } = {}) {
        if (!Array.isArray(scoredActivities)) {
            return [];
        }

        const remaining = [...scoredActivities].sort(
            (a, b) => this._getScore(b) - this._getScore(a)
        );

        const groups = [];

        while (remaining.length > 0) {
            const seed = remaining.shift();

            const group = [seed];

            while (group.length < this.maxActivitiesPerGroup) {
                const candidateIndex = this._findBestCandidate(
                    group,
                    remaining,
                    groupBudget
                );

                if (candidateIndex === -1) {
                    break;
                }

                const [candidate] = remaining.splice(candidateIndex, 1);

                group.push(candidate);
            }

            groups.push(this._createGroup(group, groupBudget));
        }

        return groups;
    }

    _findBestCandidate(group, remaining, groupBudget) {
        const seed = group[0];

        const candidates = [];

        for (let index = 0; index < remaining.length; index++) {
            const candidate = remaining[index];

            if (!this._hasComparableQuality(seed, candidate)) {
                continue;
            }

            if (!this._isCloseEnoughToGroup(candidate, group)) {
                continue;
            }

            const projectedCost = this._getGroupCost(group) +
                this._getActivityCost(candidate);

            const overrun = this._getBudgetOverrun(
                projectedCost,
                groupBudget
            );

            const distance = this._getAverageDistance(
                candidate,
                group
            );

            candidates.push({
                index,
                candidate,
                overrun,
                distance,
                score: this._getScore(candidate),
            });
        }

        if (candidates.length === 0) {
            return -1;
        }

        /*
         * Among activities of comparable quality and proximity:
         *
         * 1. Prefer the combination with the smallest budget overrun.
         * 2. Then prefer the higher-quality activity.
         * 3. Then prefer the closest activity.
         */
        candidates.sort((a, b) => {
            if (a.overrun !== b.overrun) {
                return a.overrun - b.overrun;
            }

            if (a.score !== b.score) {
                return b.score - a.score;
            }

            return a.distance - b.distance;
        });

        return candidates[0].index;
    }

    _hasComparableQuality(seed, candidate) {
        const seedScore = this._getOriginalScore(seed);
        const candidateScore = this._getOriginalScore(candidate);

        return Math.abs(seedScore - candidateScore) <= this.scoreDifference;
    }

    _isCloseEnoughToGroup(candidate, group) {
        return group.every(groupItem => {
            const distance = Location.distanceBetween(
                candidate.activity,
                groupItem.activity
            );

            return Number.isFinite(distance) &&
                distance <= this.proximityKm;
        });
    }

    _getAverageDistance(candidate, group) {
        if (group.length === 0) {
            return 0;
        }

        const distances = group.map(groupItem =>
            Location.distanceBetween(
                candidate.activity,
                groupItem.activity
            )
        );

        const validDistances = distances.filter(
            distance => Number.isFinite(distance)
        );

        if (validDistances.length === 0) {
            return Infinity;
        }

        return validDistances.reduce(
            (sum, distance) => sum + distance,
            0
        ) / validDistances.length;
    }

    _getActivityCost(scoredActivity) {
        if (Number.isFinite(Number(scoredActivity?.estimatedCost))) {
            return Number(scoredActivity.estimatedCost);
        }

        if (
            scoredActivity?.activity &&
            typeof scoredActivity.activity.getEstimatedCost === 'function'
        ) {
            return Number(
                scoredActivity.activity.getEstimatedCost(
                    scoredActivity.numberOfPeople || 1
                )
            ) || 0;
        }

        return 0;
    }

    _getGroupCost(group) {
        return group.reduce(
            (total, item) => total + this._getActivityCost(item),
            0
        );
    }

    _getBudgetOverrun(cost, budget) {
        const numericBudget = Number(budget) || 0;

        if (numericBudget <= 0) {
            return 0;
        }

        return Math.max(0, cost - numericBudget);
    }

    _getOriginalScore(item) {
        return Number(
            item?.originalScore ?? item?.score ?? 0
        );
    }

    _getScore(item) {
        return Number(item?.score ?? 0);
    }

    _createGroup(members, groupBudget) {
        const activities = members.map(member => member.activity);

        const totalCost = this._getGroupCost(members);

        const averageScore =
            members.reduce(
                (sum, member) => sum + this._getScore(member),
                0
            ) / members.length;

        const qualityScore =
            members.reduce(
                (sum, member) => sum + this._getOriginalScore(member),
                0
            ) / members.length;

        return {
            activities,
            members,
            representative: activities[0] ?? null,
            score: averageScore,
            qualityScore,
            totalCost,
            budget: Number(groupBudget) || 0,
            overBudget: this._getBudgetOverrun(
                totalCost,
                groupBudget
            ),
        };
    }
}

module.exports = ProximityGrouper;