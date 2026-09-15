const ItineraryPlanDTO =
    require('./dto/ItineraryPlanDTO');

class ItineraryPlanAssembler {
    static toResponse(
        planningResult,
        request
    ) {
        if (!planningResult) {
            return null;
        }

        return {
            plan:
                ItineraryPlanDTO({
                    residency:
                        planningResult.residency,

                    days:
                        planningResult.days ??
                        [],

                    breakfastSlots:
                        planningResult
                            .breakfastSlots ??
                        [],

                    nightActivities:
                        planningResult
                            .nightActivities ??
                        [],

                    meals:
                        request?.meals ??
                        planningResult.meals ??
                        [],

                    budget:
                        planningResult.budget
                            ?.toJSON
                            ? planningResult
                                .budget
                                .toJSON()
                            : planningResult
                                .budget ??
                              null,

                    warnings:
                        planningResult
                            .warnings ??
                        [],
                }),
        };
    }
}

module.exports =
    ItineraryPlanAssembler;