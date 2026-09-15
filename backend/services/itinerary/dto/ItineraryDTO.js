
function ItineraryDTO(itinerary) {
  if (!itinerary) return null;

  return {
    id: itinerary.id,
    userId: itinerary.userId,

    title: itinerary.title,
    description: itinerary.description,

    destination: itinerary.destination,
    country: itinerary.country,

    duration: itinerary.duration,
    budget: itinerary.budget,
    nbrOfPeople: itinerary.nbrOfPeople,

    typeSuggestion: itinerary.typeSuggestion,
    typeItinerary: itinerary.typeItinerary,

    itineraryActivityPreferences:
      itinerary.itineraryActivityPreferences ?? [],

    residenceId: itinerary.residenceId ?? null,

    plans: itinerary.plans ?? [],

    createdAt: itinerary.createdAt,
  };
}

module.exports = ItineraryDTO;