/**
 * Plan — a single day's itinerary block.
 * Replaces BasicPlan + PlanFactory (the factory added no value — it was
 * `return new BasicPlan(data)` with no decision logic).
 */
class Plan {
  constructor({
    id, itineraryId, title, description, date,
    dayNumber, activities = [], restaurants = [],
    note = '', createdAt = new Date(),
  }) {
    this.id          = id;
    this.itineraryId = itineraryId;
    this.title       = title;
    this.description = description;
    this.date = date ? new Date(date) : null;;
    this.dayNumber   = dayNumber;
    this.activities  = activities;
    this.restaurants = restaurants;
    this.note        = note;
    this.createdAt   = createdAt;
  }

  addActivity(activityId)   { this.activities.push(activityId); }
  addRestaurant(restaurantId) { this.restaurants.push(restaurantId); }
  setNote(note)             { this.note = note; }

  getSummary() {
    return {
      title:           this.title,
      date:            this.date,
      activitiesCount: this.activities.length,
      mealsCount:      this.restaurants.length,
    };
  }

  toJSON() {
    return {
      id:          this.id,
      itineraryId: this.itineraryId,
      title:       this.title,
      description: this.description,
      date:        this.date,
      dayNumber:   this.dayNumber,
      activities:  this.activities,
      restaurants: this.restaurants,
      note:        this.note,
      createdAt:   this.createdAt,
    };
  }

  removeActivity(activityId) {
    this.activities = this.activities.filter(
      id => id.toString() !== activityId.toString()
    );
  }

  removeRestaurant(restaurantId) {
    this.restaurants = this.restaurants.filter(
      id => id.toString() !== restaurantId.toString()
    );
  }

  hasActivity(activityId) {
    return this.activities.some(
      id => id.toString() === activityId.toString()
    );
  }

  hasRestaurant(restaurantId) {
    return this.restaurants.some(
      id => id.toString() === restaurantId.toString()
    );
  }

  getActivitiesCount() {
    return this.activities.length;
  }

  getRestaurantsCount() {
    return this.restaurants.length;
  }
}

module.exports = Plan;