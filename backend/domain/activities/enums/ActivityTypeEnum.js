
const ActivityTypeEnum = Object.freeze({
  MUSEUM:     'museum',
  NATURE:     'nature',
  BEACH:      'beach',
  HISTORICAL: 'historical landmark',
  TOURIST:    'tourist attraction',

  NIGHTLIFE:  'nightlife',
  MUSIC:      'music',
  CINEMA:     'cinema',
  CRUISE:     'cruise',
  MARKET:     'market',

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