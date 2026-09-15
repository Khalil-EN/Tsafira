class SoftBudgetScore {
    /**
     * Produces a soft affordability score in the same spirit
     * as WeightedResidenceScorer.
     *
     * Important:
     * - Budget is NOT a hard constraint.
     * - Cheaper options are preferred.
     * - Options over budget remain selectable.
     * - Large overruns are progressively penalised.
     */
    static calculate(cost, budget) {
        const numericCost = Number(cost) || 0;
        const numericBudget = Number(budget) || 0;

        if (numericBudget <= 0) {
            return 1;
        }

        if (numericCost <= numericBudget) {
            return 1 - (numericCost / numericBudget) * 0.5;
        }

        const overBudgetRatio =
            (numericCost - numericBudget) / numericBudget;

        return Math.max(
            0,
            0.5 - overBudgetRatio
        );
    }
}

module.exports = SoftBudgetScore;