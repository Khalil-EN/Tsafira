class BudgetAllocationPolicy {
    static allocate(totalBudget) {
        const budget =
            Number(totalBudget) || 0;

        if (budget <= 0) {
            return {
                accommodation: 0,
                food: 0,
                activities: 0,
                transport: 0,
            };
        }

        return {
            accommodation:
                budget * 0.40,

            food:
                budget * 0.30,

            activities:
                budget * 0.20,

            transport:
                budget * 0.10,
        };
    }
}

module.exports =
    BudgetAllocationPolicy;