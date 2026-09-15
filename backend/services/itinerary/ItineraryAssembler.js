const ItineraryDTO = require('./dto/ItineraryDTO');

const ItineraryAssembler = {
  toDTO(itinerary) {
    return ItineraryDTO(itinerary);
  },

  toDTOList(itineraries) {
    return itineraries.map(itinerary =>
      ItineraryAssembler.toDTO(itinerary)
    );
  },
};

module.exports = ItineraryAssembler;