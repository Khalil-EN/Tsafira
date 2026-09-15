const ItineraryDAO =
    require('../../dao/itineraryDAO');

const ItineraryFactory =
    require('../../domain/itineraries/ItineraryFactory');

const TripPlanningRequest =
    require('../../domain/itineraries/TripPlanningRequest');

const ScoringConfig =
    require('../../domain/itineraries/ScoringConfig');

const ItineraryPlannerFactory =
    require('../../domain/itineraries/ItineraryPlannerFactory');

const ItineraryAssembler =
    require('./ItineraryAssembler');

const ItineraryPlanAssembler =
    require('./plan/ItineraryPlanAssembler');

const NotFoundError =
    require('../../exceptions/NotFoundError');

const ItineraryService = {
    async createItinerary(data) {
        const raw =
            await ItineraryDAO.create(
                data
            );

        const itinerary =
            ItineraryFactory.create(
                raw
            );

        return ItineraryAssembler.toDTO(
            itinerary
        );
    },

    async getItineraryById(id) {
        const itinerary =
            await ItineraryService
                ._getItineraryDomainById(
                    id
                );

        if (!itinerary) {
            throw new NotFoundError(
                'Itinerary not found'
            );
        }

        return ItineraryAssembler.toDTO(
            itinerary
        );
    },

    async getItinerariesByUser(
        userId
    ) {
        const rawList =
            await ItineraryDAO.getByUserId(
                userId
            );

        const itineraries =
            rawList.map(
                raw =>
                    ItineraryFactory.create(
                        raw
                    )
            );

        return ItineraryAssembler.toDTOList(
            itineraries
        );
    },

    async updateItinerary(
        id,
        updates
    ) {
        const raw =
            await ItineraryDAO.update(
                id,
                updates
            );

        if (!raw) {
            throw new NotFoundError(
                'Itinerary not found'
            );
        }

        const itinerary =
            ItineraryFactory.create(
                raw
            );

        return ItineraryAssembler.toDTO(
            itinerary
        );
    },

    async deleteItinerary(id) {
        return await ItineraryDAO.delete(
            id
        );
    },

    async _getItineraryDomainById(
        id
    ) {
        const raw =
            await ItineraryDAO.getById(
                id
            );

        if (!raw) {
            return null;
        }

        return ItineraryFactory.create(
            raw
        );
    },

    buildRequest(
        normalisedPreferences
    ) {
        return TripPlanningRequest.from(
            normalisedPreferences
        );
    },

    buildSuggestion(
        request,
        activities,
        restaurants,
        residencies,
        nightActivities
    ) {
        const config =
            ScoringConfig.fromRequest(
                request
            );

        const planner =
            ItineraryPlannerFactory.create(
                request,
                config
            );

        const rawPlan =
            planner.plan(
                activities,
                restaurants,
                residencies,
                nightActivities,
                {
                    totalBudget:
                        config.maxBudget,

                    foodBudget:
                        config.foodBudget,

                    activityBudget:
                        config.activityBudget,

                    transportBudget:
                        config.transportBudget,
                }
            );

        console.log(
            'Generated itinerary plan:',
            rawPlan
        );

        return ItineraryPlanAssembler.toResponse(
            rawPlan,
            request
        );
    },
};

module.exports =
    ItineraryService;