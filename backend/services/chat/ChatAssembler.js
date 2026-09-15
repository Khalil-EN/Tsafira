const ConversationDTO =
    require("./dto/ConversationDTO");

const MessageDTO =
    require("./dto/MessageDTO");

const MessageSenderDTO =
    require("./dto/MessageSenderDTO");


class ChatAssembler {

    // ============================================================
    // MESSAGE SENDER
    // ============================================================

    static toMessageSenderDTO(sender) {

        if (!sender) {
            return null;
        }

        return new MessageSenderDTO({
            id:
                sender._id?.toString() ??
                sender.id?.toString() ??
                null,

            firstName:
                sender.firstName ?? "",

            lastName:
                sender.lastName ?? "",

            profilePicture:
                sender.profilePicture ?? null,
        });
    }


    // ============================================================
    // MESSAGE
    // ============================================================

    static toMessageDTO(message) {

      if (!message) {
          return null;
      }

      let sender;

      if (
          message.senderType === "ai"
      ) {

          sender =
              new MessageSenderDTO({
                  id: "ai",

                  firstName:
                      "Travel & App",

                  lastName:
                      "Assistant",

                  profilePicture:
                      null,
              });

      } else {

          sender =
              this.toMessageSenderDTO(
                  message.sender
              );
      }


      return new MessageDTO({

          id:
              message._id?.toString() ??
              message.id?.toString() ??
              null,

          conversationId:
              message.conversation?._id?.toString() ??
              message.conversation?.toString() ??
              message.conversationId?.toString() ??
              null,

          sender,

          content:
              message.content ?? "",

          createdAt:
              message.createdAt ?? null,
      });
  }


    static toMessageDTOs(messages) {

        if (!Array.isArray(messages)) {
            return [];
        }

        return messages
            .map(message =>
                this.toMessageDTO(message)
            )
            .filter(Boolean);
    }


    // ============================================================
    // CONVERSATION
    // ============================================================

    static toConversationDTO(
        conversation,
        currentUserId
    ) {

        if (!conversation) {
            return null;
        }

        const currentId =
            currentUserId?.toString() ?? null;


        // --------------------------------------------------------
        // PARTICIPANTS
        // --------------------------------------------------------

        const participants =
            Array.isArray(conversation.participants)
                ? conversation.participants
                    .map(participant =>
                        this.toMessageSenderDTO(
                            participant
                        )
                    )
                    .filter(Boolean)
                : [];


        // --------------------------------------------------------
        // OTHER PARTICIPANT
        // --------------------------------------------------------

        const otherParticipant =
            participants.find(participant => {

                if (!participant?.id) {
                    return false;
                }

                return participant.id.toString() !== currentId;

            }) ?? null;


        // --------------------------------------------------------
        // LAST MESSAGE SENDER
        // --------------------------------------------------------

        const lastMessageSenderId =
            conversation.lastMessageSender?._id
                ?.toString() ??

            conversation.lastMessageSender?.id
                ?.toString() ??

            conversation.lastMessageSender
                ?.toString() ??

            null;


        // --------------------------------------------------------
        // READ STATE
        // --------------------------------------------------------

        const readBy =
            Array.isArray(
                conversation.lastMessageReadBy
            )
                ? conversation.lastMessageReadBy
                    .map(id =>
                        id?.toString()
                    )
                : [];


        // --------------------------------------------------------
        // UNREAD
        //
        // A conversation is unread only when:
        //
        // 1. There is a last-message sender
        // 2. That sender is NOT the current user
        // 3. Current user hasn't read the last message
        // --------------------------------------------------------

        const unread =
            currentId !== null &&
            lastMessageSenderId !== null &&
            lastMessageSenderId !== currentId &&
            !readBy.includes(currentId);


        // --------------------------------------------------------
        // DTO
        // --------------------------------------------------------

        return new ConversationDTO({

            id:
                conversation._id?.toString() ??
                conversation.id?.toString() ??
                null,

            type:
                conversation.type ?? "direct",

            participants,

            otherParticipant,

            lastMessage:
                conversation.lastMessage ?? null,

            lastMessageAt:
                conversation.lastMessageAt ?? null,

            lastMessageSenderId,

            unread,

            createdAt:
                conversation.createdAt ?? null,

            updatedAt:
                conversation.updatedAt ?? null,
        });
    }


    static toConversationDTOs(
        conversations,
        currentUserId
    ) {

        if (!Array.isArray(conversations)) {
            return [];
        }

        return conversations
            .map(conversation =>
                this.toConversationDTO(
                    conversation,
                    currentUserId
                )
            )
            .filter(Boolean);
    }
}


module.exports = ChatAssembler;