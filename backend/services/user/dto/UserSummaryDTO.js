class UserSummaryDTO {
  constructor({
    id,
    firstName,
    lastName,
    email,
    profilePicture = null,
    role,
    status,
    isActive,
  }) {
    this.id            = id;
    this.firstName     = firstName;
    this.lastName      = lastName;
    this.email         = email;
    this.profilePicture = profilePicture;
    this.role          = role;
    this.status        = status;
    this.isActive      = isActive;
  }
}

module.exports = UserSummaryDTO;