const AnalyticsEvent = require('../schemas/analyticsEventSchema');

// Only these fields may be used by the event-count aggregation.
const ALLOWED_GROUP_BY = new Set([
  'event',
  'userId',
]);

function parseDate(value, fieldName) {
  if (!value) {
    return null;
  }

  const date = new Date(value);

  if (Number.isNaN(date.getTime())) {
    throw new Error(`Invalid analytics ${fieldName} date`);
  }

  return date;
}

function buildDateMatch(from, to) {
  const fromDate = parseDate(from, 'from');
  const toDate   = parseDate(to, 'to');

  if (!fromDate && !toDate) {
    return {};
  }

  if (fromDate && toDate && fromDate > toDate) {
    throw new Error('Analytics "from" date must be before "to" date');
  }

  const createdAt = {};

  if (fromDate) {
    createdAt.$gte = fromDate;
  }

  if (toDate) {
    createdAt.$lte = toDate;
  }

  return { createdAt };
}

const AnalyticsDAO = {

  // ── Write a single analytics event ─────────────────────────────────────

  /**
   * Writes one analytics event.
   *
   * Analytics must never break the main application request,
   * so database errors are swallowed and logged.
   */
  async log(data) {
    try {
      await new AnalyticsEvent(data).save();
    } catch (err) {
      console.error(
        '[Analytics] Failed to log event:',
        err.message
      );
    }
  },

  // ── Event counts ────────────────────────────────────────────────────────

  /**
   * Returns analytics event counts.
   *
   * Supported groupBy values:
   *   - event
   *   - userId
   */
  async getEventCounts({
    from,
    to,
    groupBy = 'event',
  } = {}) {

    if (!ALLOWED_GROUP_BY.has(groupBy)) {
      throw new Error(
        `Invalid analytics groupBy: ${groupBy}`
      );
    }

    const dateMatch = buildDateMatch(from, to);

    return await AnalyticsEvent.aggregate([
      {
        $match: dateMatch,
      },

      {
        $group: {
          _id: `$${groupBy}`,
          count: {
            $sum: 1,
          },
        },
      },

      {
        $sort: {
          count: -1,
        },
      },
    ]);
  },

  // ── Daily active users ─────────────────────────────────────────────────

  /**
   * Returns the number of unique users who generated
   * analytics events on each day.
   *
   * Anonymous events are excluded because userId === null.
   */
  async getDailyActiveUsers({
    from,
    to,
  } = {}) {

    const dateMatch = buildDateMatch(from, to);

    const match = {
      ...dateMatch,
      userId: {
        $ne: null,
      },
    };

    return await AnalyticsEvent.aggregate([
      {
        $match: match,
      },

      // First group:
      // one record per user per day.
      {
        $group: {
          _id: {
            date: {
              $dateToString: {
                format: '%Y-%m-%d',
                date: '$createdAt',
              },
            },
            userId: '$userId',
          },
        },
      },

      // Second group:
      // count unique users for each day.
      {
        $group: {
          _id: '$_id.date',
          users: {
            $sum: 1,
          },
        },
      },

      {
        $sort: {
          _id: 1,
        },
      },
    ]);
  },

  // ── Recent events ───────────────────────────────────────────────────────

  /**
   * Returns the most recent analytics events.
   *
   * Optional filters:
   *   - userId
   *   - event
   */
  async getRecentEvents({
    limit = 100,
    userId = null,
    event = null,
  } = {}) {

    // Keep limit safe even if this method is called directly.
    const parsedLimit = Number.parseInt(limit, 10);

    const safeLimit =
      Number.isFinite(parsedLimit) && parsedLimit > 0
        ? Math.min(parsedLimit, 500)
        : 100;

    const match = {};

    if (userId) {
      match.userId = userId;
    }

    if (event) {
      match.event = event;
    }

    return await AnalyticsEvent
      .find(match)
      .sort({ createdAt: -1 })
      .limit(safeLimit)
      .populate(
        'userId',
        'firstName lastName email'
      )
      .lean();
  },
};

module.exports = AnalyticsDAO;