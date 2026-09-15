const LocationDAO = require('../../dao/locationDAO');
const createLocationInstance = require('../../domain/locations/locationFactory');

/**
 * Pure persistence service — no domain logic lives here.
 *
 * Distance calculation belongs on the Location domain object.
 * Callers that need it should work with Location instances directly:
 *
 *   const a = await LocationService.getLocationById(id1);
 *   const b = await LocationService.getLocationById(id2);
 *   const km = a.calculateDistance(b);
 *
 * SystemManager.getDistanceBetween() follows this pattern.
 */
const LocationService = {
  async createLocation(data) {
    const raw = await LocationDAO.create(data);
    return createLocationInstance(raw);
  },

  async getLocationById(id) {
    const doc = await LocationDAO.getById(id);
    return createLocationInstance(doc);
  },

  async getAllLocations(filter = {}) {
    const list = await LocationDAO.getAll(filter);
    return list.map(createLocationInstance);
  },

  async updateLocation(id, updates) {
    const doc = await LocationDAO.update(id, updates);
    return createLocationInstance(doc);
  },

  async deleteLocation(id) {
    return await LocationDAO.delete(id);
  },
};

module.exports = LocationService;