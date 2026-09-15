class MessageSenderDTO {
  constructor({
    id,
    firstName,
    lastName,
    profilePicture = null,
  }) {
    this.id = id;
    this.firstName = firstName;
    this.lastName = lastName;
    this.profilePicture = profilePicture;

    Object.freeze(this);
  }
}

module.exports = MessageSenderDTO;