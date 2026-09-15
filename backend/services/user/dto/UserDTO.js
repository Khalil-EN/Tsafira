class UserDTO {
  constructor({
    id,
    firstName,
    lastName,
    email,
    phoneNumber,
    birthDate,
    profilePicture = null,
    role,
  }) {
    this.id = id;
    this.firstName = firstName;
    this.lastName = lastName;
    this.email = email;
    this.phoneNumber = phoneNumber;
    this.birthDate = birthDate;
    this.profilePicture = profilePicture;
    this.role = role;

    Object.freeze(this);
  }
}

module.exports = UserDTO;