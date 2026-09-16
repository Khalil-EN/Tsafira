class MealBudgetPolicy {
    static allocate(
        foodBudget,
        days,
        meals
    ) {
        const budget =
            Number(foodBudget) || 0;

        const numberOfDays =
            Number(days) || 0;

        if (
            budget <= 0 ||
            numberOfDays <= 0
        ) {
            return {
                breakfast: 0,
                lunch: 0,
                dinner: 0,
            };
        }

        const requested =
            new Set(
                (meals || [])
                    .filter(
                        meal =>
                            typeof meal ===
                            'string'
                    )
                    .map(
                        meal =>
                            meal
                                .trim()
                                .toLowerCase()
                    )
            );

        const dailyBudget =
            budget / numberOfDays;

        /*
         * Breakfast only
         */
        if (
            requested.size === 1 &&
            requested.has('breakfast')
        ) {
            return {
                breakfast:
                    dailyBudget,

                lunch: 0,

                dinner: 0,
            };
        }

        /*
         * Lunch only
         */
        if (
            requested.size === 1 &&
            requested.has('lunch')
        ) {
            return {
                breakfast: 0,

                lunch:
                    dailyBudget,

                dinner: 0,
            };
        }

        /*
         * Dinner only
         */
        if (
            requested.size === 1 &&
            requested.has('dinner')
        ) {
            return {
                breakfast: 0,

                lunch: 0,

                dinner:
                    dailyBudget,
            };
        }

        /*
         * Breakfast + lunch
         */
        if (
            requested.has('breakfast') &&
            requested.has('lunch') &&
            !requested.has('dinner')
        ) {
            return {
                breakfast:
                    dailyBudget * 0.30,

                lunch:
                    dailyBudget * 0.70,

                dinner: 0,
            };
        }

        /*
         * Lunch + dinner
         */
        if (
            requested.has('lunch') &&
            requested.has('dinner') &&
            !requested.has('breakfast')
        ) {
            return {
                breakfast: 0,

                lunch:
                    dailyBudget * 0.50,

                dinner:
                    dailyBudget * 0.50,
            };
        }

        /*
         * Breakfast + dinner
         */
        if (
            requested.has('breakfast') &&
            requested.has('dinner') &&
            !requested.has('lunch')
        ) {
            return {
                breakfast:
                    dailyBudget * 0.35,

                lunch: 0,

                dinner:
                    dailyBudget * 0.65,
            };
        }

        /*
         * Breakfast + lunch + dinner
         */
        if (
            requested.has('breakfast') &&
            requested.has('lunch') &&
            requested.has('dinner')
        ) {
            return {
                breakfast:
                    dailyBudget * 0.20,

                lunch:
                    dailyBudget * 0.40,

                dinner:
                    dailyBudget * 0.40,
            };
        }

        /*
         * No recognized meals.
         */
        return {
            breakfast: 0,
            lunch: 0,
            dinner: 0,
        };
    }
}

module.exports =
    MealBudgetPolicy;