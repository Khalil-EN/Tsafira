/**
 * Base class for all operational application errors.
 * `isOperational: true` lets crash reporters distinguish expected domain
 * errors from programmer bugs (null dereference, missing require, etc.).
 */
class AppError extends Error {
  constructor(message, statusCode = 500) {
    super(message);
    this.name          = this.constructor.name;
    this.statusCode    = statusCode;
    this.isOperational = true;
    Error.captureStackTrace(this, this.constructor);
  }
}

module.exports = AppError;