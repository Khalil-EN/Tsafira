const InvalidRequestTypeError = require('./exceptions/InvalidRequestTypeError');


class RequestHandlerRegistry {
  constructor() {
    this._handlers = {};
  }

  /**
   * @param {string}   type   
   * @param {{ onAccept(request): Promise<void> }} handler
   */
  register(type, handler) {
    if (typeof handler.onAccept !== 'function') {
      throw new Error(`Handler for "${type}" must implement onAccept(request)`);
    }
    this._handlers[type] = handler;
  }

  /**
   * @throws {InvalidRequestTypeError} 
   */
  async dispatch(request) {
    const handler = this._handlers[request.type];
    if (!handler) throw new InvalidRequestTypeError(request.type);
    await handler.onAccept(request);
  }
}

module.exports = new RequestHandlerRegistry();