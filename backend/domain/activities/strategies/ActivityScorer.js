class ActivityScorer {
    score(activity) {
        throw new Error(
            `${this.constructor.name} must implement score(activity)`
        );
    }

    scoreAll(activities) {
        return activities.map(activity => ({
            activity,
            score: this.score(activity),
            isFar: false,
        }));
    }
}

module.exports = ActivityScorer;