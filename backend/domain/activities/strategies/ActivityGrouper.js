/** Abstract base — subclasses must implement group(scoredActivities). */
class ActivityGrouper {
  group(scoredActivities) {
    throw new Error(`${this.constructor.name} must implement group(scoredActivities)`);
  }
}

module.exports = ActivityGrouper;