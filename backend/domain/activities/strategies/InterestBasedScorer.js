const ActivityScorer =
    require('./ActivityScorer');

class InterestBasedScorer
    extends ActivityScorer {

    constructor({
        interests = [],
    } = {}) {
        super();

        this.interests =
            Array.isArray(interests)
                ? interests
                : [];
    }

    score(activity) {
        let score = 0;

        if (
            this.interests.includes(
                activity.activityType
            )
        ) {
            score += 100;
        }

        score +=
            Math.log1p(
                activity.numberOfReviews || 0
            ) /
            Math.log1p(1000);

        score +=
            (activity.rating || 0) * 10;

        return score;
    }
}

module.exports = InterestBasedScorer;