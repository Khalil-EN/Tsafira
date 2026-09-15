class PlanningResult {
  constructor({
    residency = null,
    days = [],
    nightActivities = [],
    budget = null,
    warnings = [],
  }) {
    this.residency = residency;
    this.days = days;
    this.nightActivities = nightActivities;
    this.budget = budget;
    this.warnings = warnings;
  }

  addWarning(message) {
    if (message && !this.warnings.includes(message)) {
      this.warnings.push(message);
    }
  }

  toJSON() {
    return {
      residency: this.residency,
      days: this.days,
      nightActivities: this.nightActivities,
      budget: this.budget,
      warnings: this.warnings,
    };
  }
}

module.exports = PlanningResult;