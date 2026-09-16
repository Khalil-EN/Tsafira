const UserItinerary = require('./UserItinerary');
const GeneratedItinerary = require('./GeneratedItinerary');


class ItineraryFactory {
  static create(data) {
    if (data.typeSuggestion === 'generated') {
      return new GeneratedItinerary(data);
    }

    return new UserItinerary(data);
  }
}

module.exports = ItineraryFactory;