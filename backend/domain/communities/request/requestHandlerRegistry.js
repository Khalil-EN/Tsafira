const InvalidRequestTypeError = require('./exceptions/InvalidRequestTypeError');

/**
 * Request handler registry — domain layer.
 *
 * The domain defines *what* accepting a request means (the contract),
 * but the concrete implementations are registered by the service layer
 * at application startup. This keeps the domain free of service imports.
 *
 * Registration (done once in requestService.js or an app bootstrap file):
 *
 *   RequestHandlerRegistry.register(RequestType.FRIEND, {
 *     async onAccept(request) {
 *       await UserService.addFriend(...);
 *       await UserService.addFriend(...);
 *     }
 *   });
 *
 * Dispatching (done by RequestService):
 *
 *   await RequestHandlerRegistry.dispatch(request);
 */
class RequestHandlerRegistry {
  constructor() {
    this._handlers = {};
  }

  /**
   * Registers a handler for a request type.
   * @param {string}   type    - a RequestType enum value
   * @param {{ onAccept(request): Promise<void> }} handler
   */
  register(type, handler) {
    if (typeof handler.onAccept !== 'function') {
      throw new Error(`Handler for "${type}" must implement onAccept(request)`);
    }
    this._handlers[type] = handler;
  }

  /**
   * Dispatches a request to its registered handler.
   * @throws {InvalidRequestTypeError} if no handler is registered for request.type
   */
  async dispatch(request) {
    const handler = this._handlers[request.type];
    if (!handler) throw new InvalidRequestTypeError(request.type);
    await handler.onAccept(request);
  }
}

// Singleton — the registry is shared across the whole application
module.exports = new RequestHandlerRegistry();