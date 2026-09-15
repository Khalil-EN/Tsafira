const systemManager =
  require("../../system/SystemManager");


const AIController = {

  async getOrCreateConversation(
    req,
    res
  ) {

    const conversation =
      await systemManager
        .getOrCreateAIConversation(
          req.user.id
        );

    return res.status(200).json({
      success: true,

      data:
        conversation,
    });
  },


  async sendMessage(
    req,
    res
  ) {

    const conversationId =
      req.body.conversationId;

    const content =
      req.body.content?.trim();


    if (!conversationId) {

      return res.status(400).json({
        success: false,

        message:
          "conversationId is required.",
      });
    }


    if (!content) {

      return res.status(400).json({
        success: false,

        message:
          "Message content cannot be empty.",
      });
    }


    const result =
      await systemManager
        .sendAIMessage(
          req.user.id,
          conversationId,
          content
        );


    return res.status(201).json({
      success: true,

      data:
        result,
    });
  },
};


module.exports =
  AIController;