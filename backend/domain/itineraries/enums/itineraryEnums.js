/**
 * Itinerary domain enumerations.
 */

const ItinerarySuggestionType = Object.freeze({
  GENERATED: 'generated',
  USER:      'user',
});

const GroupType = Object.freeze({
  JUST_ME:  'Just Me',
  A_COUPLE: 'A Couple',
  GROUP:    'Group',
});

module.exports = { ItinerarySuggestionType, GroupType };