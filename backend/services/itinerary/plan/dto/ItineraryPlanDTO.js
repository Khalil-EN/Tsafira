function ItineraryPlanDTO({
    residency = null,
    days = [],
    breakfastSlots = [],
    nightActivities = [],
    meals = [],
    budget = null,
    warnings = [],
}) {
    return {
        residency,

        days,

        breakfastSlots,

        nightActivities,

        meals,

        budget,

        warnings,
    };
}

module.exports =
    ItineraryPlanDTO;