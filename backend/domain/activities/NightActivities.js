const Activity = require('./BasicActivity');

/**
 * Curated static night activities appended to every generated itinerary.
 * Defined here as Activity instances so they carry the same shape and methods
 * as any other activity in the plan.
 *
 * These are seed data that belong to the activity domain, not to the assembler.
 */
const NIGHT_ACTIVITIES = [
  new Activity({ name: 'Sky Lounge Bar',     activitytype: 'nightlife', numberofreviews: 230, rating: 4.6, image: 'https://example.com/images/sky-lounge.jpg',       latitude: 40.7561, longitude: -73.9864 }),
  new Activity({ name: 'Jazz & Blues Club',  activitytype: 'music',     numberofreviews: 180, rating: 4.8, image: 'https://example.com/images/jazz-blues.jpg',        latitude: 40.7401, longitude: -73.9947 }),
  new Activity({ name: 'Moonlight Cinema',   activitytype: 'cinema',    numberofreviews: 95,  rating: 4.4, image: 'https://example.com/images/moonlight-cinema.jpg',  latitude: 40.7333, longitude: -73.9872 }),
  new Activity({ name: 'Night River Cruise', activitytype: 'cruise',    numberofreviews: 120, rating: 4.7, image: 'https://example.com/images/night-cruise.jpg',      latitude: 40.7032, longitude: -74.0170 }),
  new Activity({ name: 'Night Market Walk',  activitytype: 'market',    numberofreviews: 75,  rating: 4.3, image: 'https://example.com/images/night-market.jpg',      latitude: 40.7429, longitude: -74.0048 }),
];

module.exports = NIGHT_ACTIVITIES;