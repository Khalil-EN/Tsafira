/**
 * ActivityTypeEnum — canonical activity type identifiers used in the DB
 * and as values throughout the domain.
 *
 * Also owns the UI-label → DB-type mapping so normalisation is never
 * duplicated across services or strategies.
 */
const ActivityTypeEnum = Object.freeze({
  // Discovery / culture
  MUSEUM:     'museum',
  NATURE:     'nature',
  BEACH:      'beach',
  HISTORICAL: 'historical landmark',
  TOURIST:    'tourist attraction',

  // Night activities
  NIGHTLIFE:  'nightlife',
  MUSIC:      'music',
  CINEMA:     'cinema',
  CRUISE:     'cruise',
  MARKET:     'market',

  /** Maps a UI label to its DB type. Returns the label unchanged if unmapped. */
  normalize(label) {
    const MAP = {
      'Museums':                   ActivityTypeEnum.MUSEUM,
      'Mountains':                 ActivityTypeEnum.NATURE,
      'Beach':                     ActivityTypeEnum.BEACH,
      'Gardens':                   ActivityTypeEnum.NATURE,
      'Cultural Attractions':      ActivityTypeEnum.HISTORICAL,
      'Entertainement Activities': ActivityTypeEnum.TOURIST,
    };
    return MAP[label] ?? label;
  },

  normalizeAll(labels) {
    return labels.map(ActivityTypeEnum.normalize);
  },
});

module.exports = ActivityTypeEnum;