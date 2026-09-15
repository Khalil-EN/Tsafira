class RestaurantAssigner {
    constructor({
        scorer,
        eligibilityPolicy,
        meals = [],
        mealBudgets = {},
        numberOfPeople = 1,
        maxRestaurantDistanceKm = 5,
    } = {}) {
        this.scorer = scorer;
        this.eligibilityPolicy = eligibilityPolicy;

        this.meals = new Set(
            meals.map(meal => meal.toLowerCase())
        );

        this.mealBudgets = {
            breakfast: Number(mealBudgets.breakfast) || 0,
            lunch: Number(mealBudgets.lunch) || 0,
            dinner: Number(mealBudgets.dinner) || 0,
        };

        this.numberOfPeople =
            Number(numberOfPeople) || 1;

        this.maxRestaurantDistanceKm =
            Number(maxRestaurantDistanceKm) || 5;
    }

    assign(days, restaurants) {
        if (
            !Array.isArray(days) ||
            !Array.isArray(restaurants)
        ) {
            return [];
        }

        const chosen = new Set();

        return days.map(day => {
            const result = {
                ...day,
                lunch: null,
                dinner: null,
            };

            /*
             * Lunch is associated with the morning activity group.
             */
            if (this.meals.has('lunch')) {
                result.lunch =
                    this._selectRestaurant({
                        restaurants,
                        meal: 'lunch',
                        budget: this.mealBudgets.lunch,
                        activities:
                            day.morningActivities ??
                            this._toActivityArray(
                                day.morningActivity
                            ),
                        chosen,
                    });
            }

            /*
             * Dinner is associated with the afternoon activity
             * group.
             */
            if (this.meals.has('dinner')) {
                result.dinner =
                    this._selectRestaurant({
                        restaurants,
                        meal: 'dinner',
                        budget: this.mealBudgets.dinner,
                        activities:
                            day.afternoonActivities ??
                            this._toActivityArray(
                                day.afternoonActivity
                            ),
                        chosen,
                    });
            }

            return result;
        });
    }

    _selectRestaurant({
      restaurants,
      meal,
      budget,
      activities,
      chosen,
  }) {
      if (
          !Array.isArray(activities) ||
          activities.length === 0
      ) {
          return null;
      }

      const candidates =
          restaurants
              .filter(restaurant =>
                  this._isEligible(
                      restaurant,
                      meal
                  )
              )
              .filter(restaurant => {
                  const key =
                      restaurant.id ??
                      restaurant.name;

                  return !chosen.has(key);
              })
              .map(restaurant => {
                  const mealCost =
                      this._getMealCost(
                          restaurant
                      );

                  const locationScore =
                      this._calculateGroupLocationScore(
                          restaurant,
                          activities
                      );

                  const budgetScore =
                      this._calculateBudgetScore(
                          mealCost,
                          budget
                      );

                  const qualityScore =
                      this._calculateQualityScore(
                          restaurant,
                          activities
                      );

                  /*
                  * Balanced selection:
                  *
                  * 45% quality
                  * 35% proximity
                  * 20% affordability
                  */
                  const score =
                      qualityScore * 0.45 +
                      locationScore * 0.35 +
                      budgetScore * 0.20;

                  return {
                      restaurant,
                      score,
                      mealCost,
                      locationScore,
                      budgetScore,
                      qualityScore,
                      overBudget:
                          this._getOverBudget(
                              mealCost,
                              budget
                          ),
                  };
              })
              .sort((a, b) => {
                  /*
                  * The FINAL score is the primary
                  * decision.
                  *
                  * Budget only breaks close ties.
                  */
                  const scoreDifference =
                      b.score - a.score;

                  if (
                      Math.abs(
                          scoreDifference
                      ) > 0.05
                  ) {
                      return scoreDifference;
                  }

                  return (
                      a.overBudget -
                      b.overBudget
                  );
              });

      if (
          candidates.length === 0
      ) {
          return null;
      }

      const selected =
          candidates[0].restaurant;

      const key =
          selected.id ??
          selected.name;

      chosen.add(key);

      return selected;
  }

    _isEligible(restaurant, meal) {
        if (!restaurant) {
            return false;
        }

        if (
            !restaurant.servesMeal ||
            !restaurant.servesMeal(meal)
        ) {
            return false;
        }

        const estimatedCost =
            this._getMealCost(restaurant);

        if (estimatedCost === null) {
            return false;
        }

        /*
         * IMPORTANT:
         *
         * We intentionally do NOT do:
         *
         *   estimatedCost > budget
         *
         * here.
         *
         * Budget is a soft preference.
         */
        if (this.eligibilityPolicy) {
            return this.eligibilityPolicy.isEligible(
                restaurant,
                {
                    meal,
                    maxCost: Infinity,
                }
            );
        }

        return true;
    }

    _getMealCost(restaurant) {
        if (
            !restaurant ||
            typeof restaurant.getEstimatedMealCost !==
                'function'
        ) {
            return null;
        }

        const cost =
            restaurant.getEstimatedMealCost(
                this.numberOfPeople
            );

        if (!Number.isFinite(Number(cost))) {
            return null;
        }

        return Number(cost);
    }

    _calculateBudgetScore(cost, budget) {
        const numericCost =
            Number(cost) || 0;

        const numericBudget =
            Number(budget) || 0;

        if (numericBudget <= 0) {
            return 1;
        }

        if (numericCost <= numericBudget) {
            /*
             * Cheaper restaurants receive a better score,
             * but we don't make price dominate quality.
             */
            return 1 -
                (numericCost / numericBudget) * 0.5;
        }

        const overrun =
            (numericCost - numericBudget) /
            numericBudget;

        /*
         * Still allow expensive restaurants, but increasingly
         * penalize them.
         */
        return Math.max(
            0,
            0.5 - overrun
        );
    }

    _getOverBudget(cost, budget) {
        const numericCost =
            Number(cost) || 0;

        const numericBudget =
            Number(budget) || 0;

        if (numericBudget <= 0) {
            return 0;
        }

        return Math.max(
            0,
            numericCost - numericBudget
        );
    }

    _calculateGroupLocationScore(
        restaurant,
        activities
    ) {
        if (
            !Array.isArray(activities) ||
            activities.length === 0
        ) {
            return 0;
        }

        const distances = activities
            .map(activity =>
                this._getDistance(
                    restaurant,
                    activity
                )
            )
            .filter(
                distance =>
                    Number.isFinite(distance)
            );

        if (distances.length === 0) {
            return 0;
        }

        /*
         * Average distance to the entire group.
         *
         * This is preferable to looking only at the first
         * activity because the restaurant should serve the
         * whole morning/afternoon group.
         */
        const averageDistance =
            distances.reduce(
                (sum, distance) =>
                    sum + distance,
                0
            ) / distances.length;

        if (
            averageDistance <= 0
        ) {
            return 1;
        }

        if (
            averageDistance >=
            this.maxRestaurantDistanceKm
        ) {
            return 0;
        }

        return (
            1 -
            averageDistance /
                this.maxRestaurantDistanceKm
        );
    }

    _getDistance(
        restaurant,
        activity
    ) {
        if (
            !restaurant ||
            !activity
        ) {
            return Infinity;
        }

        /*
         * Both restaurant and activity are expected to expose
         * coordinates through the same location abstraction.
         *
         * We first try the domain Location helper if available.
         */
        try {
            const Location =
                require('../../locations/Location');

            return Location.distanceBetween(
                restaurant,
                activity
            );
        } catch (error) {
            /*
             * If the location abstraction cannot calculate a
             * distance, don't reject the restaurant.
             */
            return Infinity;
        }
    }

    _calculateQualityScore(
        restaurant,
        activities
    ) {
        if (!this.scorer) {
            return 0;
        }

        /*
         * Score the restaurant against every activity in the
         * group and use the average.
         *
         * This prevents the first activity from dominating the
         * restaurant selection.
         */
        if (
            typeof this.scorer.score !==
            'function'
        ) {
            return 0;
        }

        if (
            !Array.isArray(activities) ||
            activities.length === 0
        ) {
            return 0;
        }

        const scores = activities
            .map(activity => {
                const score =
                    this.scorer.score(
                        restaurant,
                        activity
                    );

                return Number(score);
            })
            .filter(
                score =>
                    Number.isFinite(score)
            );

        if (scores.length === 0) {
            return 0;
        }

        const average =
            scores.reduce(
                (sum, score) =>
                    sum + score,
                0
            ) / scores.length;

        /*
         * The scorer may use an arbitrary scale, so normalize
         * only when it is clearly outside [0, 1].
         */
        if (average >= 0 && average <= 1) {
            return average;
        }

        return 1 /
            (1 + Math.exp(-average / 10));
    }

    _toActivityArray(activity) {
        return activity
            ? [activity]
            : [];
    }
}

module.exports = RestaurantAssigner;