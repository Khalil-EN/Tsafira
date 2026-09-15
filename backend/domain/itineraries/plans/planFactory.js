const BasicPlan = require('./BasicPlan');

class PlanFactory {
  static create(data) {
    return new BasicPlan(data);
  }
}

module.exports = PlanFactory;