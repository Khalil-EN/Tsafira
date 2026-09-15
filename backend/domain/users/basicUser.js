const { UserRole, UserStatus } = require('./enums/userEnums');

class BaseUser {
  constructor({
    id,
    firstName,
    lastName,
    phoneNumber,
    email,
    birthDate,
    passwordHash,

    profilePicture = null,
    location = null,
    lastLoginDate = null,

    status = UserStatus.ACTIVE,
    role = UserRole.FREEMIUM,
    isActive = true,

    friends = [],
    communities = [],

    suggestionCountToday = 0,
    lastSuggestionDate = null,
    createdAt = new Date(),

    emailVerified = false,
    emailVerificationCode = null,
    emailVerificationExpiresAt = null,
    refreshToken = null,
    fcmToken = null,
    postsCount = 0,
  }) {

    this.id = id;

    this.firstName =
      BaseUser.normalizeName(firstName);

    this.lastName =
      BaseUser.normalizeName(lastName);

    this.email =
      BaseUser.normalizeEmail(email);

    this.phoneNumber =
      BaseUser.normalizePhoneNumber(phoneNumber);

    this.birthDate =
      new Date(birthDate);

    this.passwordHash =
      passwordHash;

    this.profilePicture =
      profilePicture || 'avatar_01';

    this.location =
      location;

    this.lastLoginDate =
      lastLoginDate
        ? new Date(lastLoginDate)
        : null;

    this.status =
      status;

    this.role =
      role;

    this.isActive =
      isActive;

    this.friends =
      friends;

    this.communities =
      communities;

    this.suggestionCountToday =
      suggestionCountToday;

    this.lastSuggestionDate =
      lastSuggestionDate;

    this.createdAt =
      new Date(createdAt);

    this.emailVerified =
      emailVerified;

    this.emailVerificationCode =
      emailVerificationCode;

    this.emailVerificationExpiresAt =
      emailVerificationExpiresAt;

    this.refreshToken =
      refreshToken;

    this.fcmToken =
      fcmToken;

    this.postsCount =
      postsCount;
  }

  // ============================================================
  // Domain normalization
  // ============================================================

  static normalizeName(value) {
    if (typeof value !== 'string') {
      return '';
    }

    return value.trim();
  }

  static normalizeEmail(value) {
    if (typeof value !== 'string') {
      return '';
    }

    return value.trim().toLowerCase();
  }

  static normalizePhoneNumber(value) {
    if (
      value === null ||
      value === undefined ||
      typeof value !== 'string'
    ) {
      return null;
    }

    const normalized = value.trim();

    return normalized === ''
      ? null
      : normalized;
  }

  // ============================================================
  // Domain behavior
  // ============================================================

  getFullName() {
    return `${this.firstName} ${this.lastName}`;
  }

  getAge() {
    const now = new Date();

    const age =
      now.getFullYear() -
      this.birthDate.getFullYear();

    const m =
      now.getMonth() -
      this.birthDate.getMonth();

    return (
      m < 0 ||
      (
        m === 0 &&
        now.getDate() < this.birthDate.getDate()
      )
    )
      ? age - 1
      : age;
  }

  updateLastLogin() {
    this.lastLoginDate = new Date();
  }

  deactivate() {
    this.status = UserStatus.INACTIVE;
    this.isActive = false;
  }

  suspend() {
    this.status = UserStatus.SUSPENDED;
    this.isActive = false;
  }

  restore() {
    this.status = UserStatus.ACTIVE;
    this.isActive = true;
  }

  canCreateCommunity() {
    return true;
  }

  canPostInCommunity() {
    return true;
  }

  canMakeSuggestion() {
    return true;
  }

  toJSON() {
    const {
      passwordHash,
      ...safeData
    } = this;

    return safeData;
  }
}

module.exports = BaseUser;