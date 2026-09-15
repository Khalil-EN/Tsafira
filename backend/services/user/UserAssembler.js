const UserDTO = require('./dto/UserDTO');
const UserSummaryDTO = require('./dto/UserSummaryDTO');
const LoginResponseDTO = require('./dto/LoginResponseDTO');

class UserAssembler {

  static toDTO(user) {
    if (!user) {
      return null;
    }

    return new UserDTO({
      id: user._id?.toString() ?? user.id,
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.email,
      phoneNumber: user.phoneNumber,
      birthDate: user.birthDate,
      profilePicture: user.profilePicture ?? null,
      role: user.role,
    });
  }

  static toSummaryDTO(user) {
    if (!user) {
        return null;
    }

    return new UserSummaryDTO({
        id: user._id?.toString() ?? user.id,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        profilePicture: user.profilePicture ?? null,
        role: user.role,
        status: user.status,
        isActive: user.isActive,
    });
    }

  static toLoginResponseDTO({
    accessToken,
    refreshToken,
    user,
  }) {

    return new LoginResponseDTO({
      accessToken,
      refreshToken,
      user: UserAssembler.toDTO(user),
    });
  }
}

module.exports = UserAssembler;