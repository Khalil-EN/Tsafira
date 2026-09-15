const {
  ReceivedRequestDTO,
  SentRequestDTO,
} = require("./dto/RequestDTO");

function assembleRequests({
  received = [],
  sent = [],
}) {
  return {
    received:
      received
        .map((request) =>
          ReceivedRequestDTO(request)
        )
        .filter(Boolean),

    sent:
      sent
        .map((request) =>
          SentRequestDTO(request)
        )
        .filter(Boolean),
  };
}

module.exports = {
  assembleRequests,
};