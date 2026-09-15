const mongoose = require("mongoose");

const {
  ValidationError,
} = require("../../exceptions");

// ======================================================
// HELPERS
// ======================================================

function isValidDate(value) {
  if (!value) return false;

  const date = new Date(value);

  return !Number.isNaN(date.getTime());
}

function validateDateRange(from, to) {
  if (from && !isValidDate(from)) {
    throw new ValidationError(
      "Invalid 'from' date."
    );
  }

  if (to && !isValidDate(to)) {
    throw new ValidationError(
      "Invalid 'to' date."
    );
  }

  if (from && to) {
    const fromDate = new Date(from);
    const toDate = new Date(to);

    if (fromDate > toDate) {
      throw new ValidationError(
        "'from' date cannot be after 'to' date."
      );
    }
  }
}

// ======================================================
// USER QUERIES
// ======================================================

function validateUsersQuery(req, res, next) {
  const {
    page = "1",
    limit = "20",
  } = req.query;

  const parsedPage = Number(page);
  const parsedLimit = Number(limit);

  if (
    !Number.isInteger(parsedPage) ||
    parsedPage < 1
  ) {
    throw new ValidationError(
      "'page' must be a positive integer."
    );
  }

  if (
    !Number.isInteger(parsedLimit) ||
    parsedLimit < 1 ||
    parsedLimit > 100
  ) {
    throw new ValidationError(
      "'limit' must be an integer between 1 and 100."
    );
  }

  req.query.page = parsedPage;
  req.query.limit = parsedLimit;

  next();
}

// ======================================================
// USER / POST ID
// ======================================================

function validateUserId(req, res, next) {
  const { id } = req.params;

  if (!mongoose.Types.ObjectId.isValid(id)) {
    throw new ValidationError(
      "Invalid ID."
    );
  }

  next();
}

// ======================================================
// ANALYTICS EVENTS
// ======================================================

function validateAnalyticsEventsQuery(req, res, next) {
  const {
    from,
    to,
    groupBy = "event",
  } = req.query;

  validateDateRange(from, to);

  const allowedGroupBy = [
    "event",
    "userId",
  ];

  if (!allowedGroupBy.includes(groupBy)) {
    throw new ValidationError(
      "'groupBy' must be 'event' or 'userId'."
    );
  }

  req.query.groupBy = groupBy;

  next();
}

// ======================================================
// ANALYTICS DAU
// ======================================================

function validateAnalyticsDauQuery(req, res, next) {
  const {
    from,
    to,
  } = req.query;

  validateDateRange(from, to);

  next();
}

// ======================================================
// ANALYTICS RECENT EVENTS
// ======================================================

function validateAnalyticsRecentQuery(
  req,
  res,
  next
) {
  const {
    limit = "100",
    event,
    userId,
  } = req.query;

  const parsedLimit = Number(limit);

  if (
    !Number.isInteger(parsedLimit) ||
    parsedLimit < 1 ||
    parsedLimit > 500
  ) {
    throw new ValidationError(
      "'limit' must be an integer between 1 and 500."
    );
  }

  if (
    userId &&
    !mongoose.Types.ObjectId.isValid(userId)
  ) {
    throw new ValidationError(
      "Invalid userId."
    );
  }

  req.query.limit = parsedLimit;

  next();
}

// ======================================================
// BROADCAST
// ======================================================

function validateBroadcast(req, res, next) {
  const {
    recipientIds,
    title,
    body,
  } = req.body;

  if (
    typeof title !== "string" ||
    !title.trim()
  ) {
    throw new ValidationError(
      "Title is required."
    );
  }

  if (
    typeof body !== "string" ||
    !body.trim()
  ) {
    throw new ValidationError(
      "Body is required."
    );
  }

  if (
    !recipientIds ||
    (
      !Array.isArray(recipientIds) &&
      recipientIds !== "all"
    )
  ) {
    throw new ValidationError(
      "recipientIds must be an array or 'all'."
    );
  }

  if (Array.isArray(recipientIds)) {
    for (const id of recipientIds) {
      if (
        typeof id !== "string" ||
        !mongoose.Types.ObjectId.isValid(id)
      ) {
        throw new ValidationError(
          "recipientIds contains an invalid user ID."
        );
      }
    }
  }

  // Normalize strings before reaching SystemManager.
  req.body.title = title.trim();
  req.body.body = body.trim();

  next();
}

// ======================================================

module.exports = {
  validateUsersQuery,
  validateUserId,
  validateAnalyticsEventsQuery,
  validateAnalyticsDauQuery,
  validateAnalyticsRecentQuery,
  validateBroadcast,
};