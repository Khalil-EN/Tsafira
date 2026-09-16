const {
    GroupType,
} = require('./enums/ItineraryEnums');

class TripPlanningRequest {
    constructor({
        groupType,
        nbrPeople,
        budget,
        days,

        interests,

        paymentPreferences,

        dietaryPreferences,

        meals,

        restaurantTags,

        country,

        city,

        accomodationType,
    }) {
        this.groupType =
            groupType;

        this.nbrPeople =
            Number(nbrPeople) || 1;

        this.budget =
            Number(budget) || 0;

        this.days =
            Number(days) || 1;

        this.interests =
            Array.isArray(interests)
                ? interests
                : [];

        this.paymentPreferences =
            Array.isArray(
                paymentPreferences
            )
                ? paymentPreferences
                : [];

        this.dietaryPreferences =
            Array.isArray(
                dietaryPreferences
            )
                ? dietaryPreferences
                : [];

        this.meals =
            Array.isArray(meals)
                ? meals
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
                : [];

        this.restaurantTags =
            Array.isArray(
                restaurantTags
            )
                ? restaurantTags
                : [];

        this.country =
            country;

        this.city =
            city;

        this.accomodationType =
            accomodationType;
    }

    resolvedPeopleCount() {
        if (
            this.groupType ===
            GroupType.JUST_ME
        ) {
            return 1;
        }

        if (
            this.groupType ===
            GroupType.A_COUPLE
        ) {
            return 2;
        }

        return this.nbrPeople;
    }

    static from(raw) {
        return new TripPlanningRequest(
            raw
        );
    }
}

module.exports =
    TripPlanningRequest;