const AnalyticsService = require('../services/infra/analytics/AnalyticsService');


const IGNORED_PATHS = ['/health', '/favicon.ico'];

function analyticsMiddleware(req, res, next) {
  if (IGNORED_PATHS.includes(req.path)) return next();

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