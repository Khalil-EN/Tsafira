const ItineraryPlanner = require('./ItineraryPlanner');

const InterestBasedScorer = require('../../activities/strategies/InterestBasedScorer');

const ProximityGrouper = require('../../activities/strategies/ProximityGrouper');

const NearActivityScorer = require('../../restaurants/strategies/NearActivityScorer');

const NearResidenceScorer = require('../../restaurants/strategies/NearResidenceScorer');

const WeightedResidenceScorer = require('../../residences/strategies/WeightedResidenceScorer');

const ActivityEligibilityPolicy = require('../../activities/ActivityEligibilityPolicy');

const RestaurantEligibilityPolicy = require('../../restaurants/RestaurantEligibilityPolicy');

const ItineraryPlannerFactory = {
    create(request, config) {
        const numberOfPeople = request.resolvedPeopleCount();

        const activityEligibilityPolicy = new ActivityEligibilityPolicy({numberOfPeople,});

        const restaurantEligibilityPolicy = new RestaurantEligibilityPolicy({numberOfPeople,});

        return new ItineraryPlanner({
            activityScorer: new InterestBasedScorer({interests: request.interests}),
            activityGrouper: new ProximityGrouper(),
            activityEligibilityPolicy,

            restaurantScorer:
                new NearActivityScorer({
                    cuisineTags: request.restaurantTags,
                    facilities: config.facilities,
                }),
            restaurantEligibilityPolicy,
            breakfastScorer: new NearResidenceScorer(),

            residenceScorer: new WeightedResidenceScorer({
                          maxBudget: config.accommodationBudget,
                          nights: request.days,
                          numberOfPeople: request.resolvedPeopleCount(),
                          minRating: config.minRating,
                          preferredAmenities: config.preferredAmenities,
                          weight: config.weight,
                      }),

            days: request.days,
            meals: request.meals,
            numberOfPeople,

            activityBudget: config.activityBudgetPerDay,
            mealBudgets: config.mealBudgets,
            accommodationBudget: config.accommodationBudget,
        });
    },
};

module.exports = ItineraryPlannerFactory;