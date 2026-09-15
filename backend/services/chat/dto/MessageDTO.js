class MessageDTO {
  constructor({
    id,
    conversationId,
    sender,
    content,
    createdAt,
  }) {
    this.id = id;
    this.conversationId = conversationId;
    this.sender = sender;
    this.content = content;
    this.createdAt = createdAt;

    Object.freeze(this);
  }
}

module.exports = MessageDTO;