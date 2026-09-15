const AnalyticsEventCountDTO =
  require('./dto/AnalyticsEventCountDTO');

const AnalyticsDailyActiveUsersDTO =
  require('./dto/AnalyticsDailyActiveUsersDTO');

const AnalyticsRecentEventDTO =
  require('./dto/AnalyticsRecentEventDTO');

class AnalyticsAssembler {

  // ── Event counts ────────────────────────────────────────────────

  static toEventCountDTO(item) {
    if (!item) {
      return null;
    }

    return new AnalyticsEventCountDTO({
      event: item._id?.toString() ?? 'unknown',
      count: item.count ?? 0,
    });
  }

  static toEventCountsDTO(items = []) {
    return items
      .map(item => AnalyticsAssembler.toEventCountDTO(item))
      .filter(Boolean);
  }

  // ── Daily active users ─────────────────────────────────────────

  static toDailyActiveUsersDTO(item) {
    if (!item) {
      return null;
    }

    return new AnalyticsDailyActiveUsersDTO({
      date: item._id?.toString() ?? null,
      users: item.users ?? 0,
    });
  }

  static toDailyActiveUsersDTOs(items = []) {
    return items
      .map(item => AnalyticsAssembler.toDailyActiveUsersDTO(item))
      .filter(Boolean);
  }

  // ── Recent events ──────────────────────────────────────────────

  static toRecentEventDTO(item) {
    if (!item) {
      return null;
    }

    const populatedUser = item.userId && typeof item.userId === 'object'
      ? item.userId
      : null;

    const userId = populatedUser
      ? populatedUser._id?.toString()
      : item.userId?.toString?.() ?? item.userId ?? null;

    const user = populatedUser
      ? {
          id: populatedUser._id?.toString(),
          firstName: populatedUser.firstName,
          lastName: populatedUser.lastName,
          email: populatedUser.email,
        }
      : null;

    return new AnalyticsRecentEventDTO({
      id: item._id?.toString() ?? item.id,
      event: item.event,
      userId,
      user,
      properties: item.properties ?? {},
      ip: item.ip ?? null,
      userAgent: item.userAgent ?? null,
      createdAt: item.createdAt ?? null,
    });
  }

  static toRecentEventsDTO(items = []) {
    return items
      .map(item => AnalyticsAssembler.toRecentEventDTO(item))
      .filter(Boolean);
  }
}

module.exports = AnalyticsAssembler;