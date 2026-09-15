class ConversationDTO {
    constructor({
        id,
        type,
        participants,
        otherParticipant = null,
        lastMessage = null,
        lastMessageAt = null,
        lastMessageSenderId = null,
        unread = false,
        createdAt = null,
        updatedAt = null,
    }) {
        this.id = id;
        this.type = type;
        this.participants = participants;
        this.otherParticipant = otherParticipant;

        this.lastMessage = lastMessage;
        this.lastMessageAt = lastMessageAt;
        this.lastMessageSenderId =
            lastMessageSenderId;

        this.unread = unread;

        this.createdAt = createdAt;
        this.updatedAt = updatedAt;

        Object.freeze(this);
    }
}

module.exports = ConversationDTO;