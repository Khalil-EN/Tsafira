class LoginResponseDTO {
  constructor({
    accessToken,
    refreshToken,
    user,
  }) {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
    this.user = user;

    Object.freeze(this);
  }
}

module.exports = LoginResponseDTO;