class DayPlanBuilder {
    static build(activityGroups, days) {
        const result = [];

        const safeGroups = Array.isArray(activityGroups)
            ? activityGroups
            : [];

        for (let day = 0; day < days; day++) {
            const morningGroup =
                safeGroups[day * 2] ?? null;

            const afternoonGroup =
                safeGroups[day * 2 + 1] ?? null;

            const morningActivities =
                morningGroup?.activities ?? [];

            const afternoonActivities =
                afternoonGroup?.activities ?? [];

            result.push({
                day: day + 1,

                /*
                 * New structure.
                 */
                morningActivities,
                afternoonActivities,

                /*
                 * Representatives are kept for compatibility
                 * with the current restaurant assignment logic.
                 */
                morningActivity:
                    morningGroup?.representative ??
                    morningActivities[0] ??
                    null,

                afternoonActivity:
                    afternoonGroup?.representative ??
                    afternoonActivities[0] ??
                    null,

                lunch: null,
                dinner: null,
            });
        }

        return result;
    }
}

module.exports = DayPlanBuilder;