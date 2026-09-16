const { GroupType } = require('./enums/itineraryEnums');

class BaseItinerary {
  constructor({
    id, userId, title, description, destination, country,
    duration, budget, nbrOfPeople, typeSuggestion, typeItinerary,
    itineraryActivityPreferences, residenceId, plans = [], createdAt,
  }) {
    this.id                           = id;
    this.userId                       = userId;
    this.title                        = title;
    this.description                  = description;
    this.destination                  = destination;
    this.country                      = country;
    this.duration                     = duration;
    this.budget                       = budget;
    this.nbrOfPeople                  = nbrOfPeople;
    this.typeSuggestion               = typeSuggestion;
    this.typeItinerary                = typeItinerary;
    this.itineraryActivityPreferences = itineraryActivityPreferences;
    this.residenceId                  = residenceId;
    this.plans                        = plans;
    this.createdAt                    = createdAt || new Date();
  }

  addPlan(plan) {
    if (!plan) {
      throw new Error('Plan is required');
    }

    this.plans.push(plan);
  }

  getSummary() {
    return { id: this.id, title: this.title, duration: this.duration, type: this.typeItinerary };
  }

  toJSON() { return { ...this }; }

  static countPeople(groupType, nbrOfPeople) {
    if (groupType === GroupType.JUST_ME)  return 1;
    if (groupType === GroupType.A_COUPLE) return 2;
    return nbrOfPeople;
  }

  static getBudgetPerPerson(budget, nbrOfPeople, days) {
    return budget / days / nbrOfPeople;
  }

  hasPlans() {
    return this.plans.length > 0;
  }

  getPlan(dayNumber) {
    return this.plans.find(plan => plan.dayNumber === dayNumber) || null;
  }

  removePlan(dayNumber) {
    const index = this.plans.findIndex(
      plan => plan.dayNumber === dayNumber
    );

    if (index === -1) return false;

    this.plans.splice(index, 1);
    return true;
  }

  getTotalPlans() {
    return this.plans.length;
  }
}

module.exports = BaseItinerary;