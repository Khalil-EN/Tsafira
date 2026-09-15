class AnalyticsRecentEventDTO {
  constructor({
    id,
    event,
    userId = null,
    user = null,
    properties = {},
    ip = null,
    userAgent = null,
    createdAt = null,
  }) {
    this.id = id;
    this.event = event;
    this.userId = userId;
    this.user = user;
    this.properties = properties;
    this.ip = ip;
    this.userAgent = userAgent;
    this.createdAt = createdAt;
  }
}

module.exports = AnalyticsRecentEventDTO;