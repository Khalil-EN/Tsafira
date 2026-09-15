const BaseUser   = require('./basicUser');
const DateRange  = require('./DateRange');
const { UserRole } = require('./enums/userEnums');

const MAX_FREE_SUGGESTIONS_PER_DAY = 5;

class FreemiumUser extends BaseUser {
  constructor(userData) {
    super({ ...userData, role: UserRole.FREEMIUM });
    this.suggestionLimit = MAX_FREE_SUGGESTIONS_PER_DAY;
  }

  canMakeSuggestion() {
    const today        = DateRange.today();
    const lastUsed     = new Date(this.lastSuggestionDate || 0);
    const usedToday    = today.contains(lastUsed);
    const currentCount = usedToday ? (this.suggestionCountToday || 0) : 0;
    return currentCount < this.suggestionLimit;
  }

  /** Returns the persistence delta — does not write to DB. */
  recordSuggestion() {
    const today        = DateRange.today();
    const lastUsed     = new Date(this.lastSuggestionDate || 0);
    const usedToday    = today.contains(lastUsed);
    const currentCount = usedToday ? (this.suggestionCountToday || 0) : 0;
    return {
      suggestionCountToday: currentCount + 1,
      lastSuggestionDate:   new Date(),
    };
  }
}

module.exports = FreemiumUser;