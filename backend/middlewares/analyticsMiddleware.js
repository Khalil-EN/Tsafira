// middleware/analyticsMiddleware.js
// Attach after auth middleware on any router you want to track.
// Logs a 'api_request' event for every call — lightweight, non-blocking.

const AnalyticsService = require('../services/infra/analytics/AnalyticsService');

// Events worth logging explicitly via SystemManager don't need this middleware.
// This is a catch-all for page/screen views and API calls you haven't
// instrumented manually yet.

const IGNORED_PATHS = ['/health', '/favicon.ico'];

function analyticsMiddleware(req, res, next) {
  if (IGNORED_PATHS.includes(req.path)) return next();

  // Fire after response so we can capture status code
  res.on('finish', () => {
    AnalyticsService.log('api_request', {
      userId:     req.user?._id || null,
      ip:         req.ip,
      userAgent:  req.headers['user-agent'],
      properties: {
        method:     req.method,
        path:       req.route?.path || req.path,
        statusCode: res.statusCode,
      },
    });
  });

  next();
}

module.exports = analyticsMiddleware;