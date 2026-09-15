/** Abstract base — subclasses must implement score(restaurant, context). */
class RestaurantScorer {
  score(restaurant, context) {
    throw new Error(`${this.constructor.name} must implement score(restaurant, context)`);
  }
}

module.exports = RestaurantScorer;