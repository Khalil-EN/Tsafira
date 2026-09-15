const AnalyticsDAO = require('../../../dao/analyticsDAO');
const AnalyticsAssembler = require('./AnalyticsAssembler');

const AnalyticsService = {

  /**
   * Log a single analytics event.
   *
   * Fire-and-forget.
   */
  log(
    event,
    {
      userId = null,
      properties = {},
      ip = null,
      userAgent = null,
    } = {}
  ) {
    AnalyticsDAO.log({
      event,
      userId,
      properties,
      ip,
      userAgent,
    });
  },

  // ── Admin queries ───────────────────────────────────────────────

  async getEventCounts(filters = {}) {
    const results = await AnalyticsDAO.getEventCounts(filters);

    return AnalyticsAssembler.toEventCountsDTO(results);
  },

  async getDailyActiveUsers(filters = {}) {
    const results =
      await AnalyticsDAO.getDailyActiveUsers(filters);

    return AnalyticsAssembler.toDailyActiveUsersDTOs(results);
  },

  async getRecentEvents(filters = {}) {
    const results =
      await AnalyticsDAO.getRecentEvents(filters);

    return AnalyticsAssembler.toRecentEventsDTO(results);
  },
};

module.exports = AnalyticsService;