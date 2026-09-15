class ResidenceScorer {
    score(residence) {
        throw new Error(
            `${this.constructor.name} must implement score(residence)`
        );
    }

    selectBest(residencies) {
        if (
            !Array.isArray(residencies) ||
            residencies.length === 0
        ) {
            return null;
        }

        let best = null;
        let bestScore = -Infinity;

        for (const residence of residencies) {
            const score =
                this.score(residence);

            if (score > bestScore) {
                bestScore = score;

                best = {
                    ...residence,
                    score,
                };
            }
        }

        return best;
    }
}

module.exports = ResidenceScorer;