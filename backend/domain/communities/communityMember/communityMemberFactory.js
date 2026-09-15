const Owner = require("./owner");
const Admin = require("./admin");
const Moderator = require("./moderator");
const RegularMember = require("./regularMember");

const CommunityMemberFactory = {
  create(data) {
    if (!data) {
      return null;
    }

    const role =
      data.role ?? "member";

    switch (role) {
      case "owner":
        return new Owner(data);

      case "admin":
        return new Admin(data);

      case "moderator":
        return new Moderator(data);

      case "member":
      default:
        return new RegularMember(data);
    }
  },

  createMany(data = []) {
    return data
      .map(item => this.create(item))
      .filter(Boolean);
  },

  promote(member, newRole) {
    if (!member) {
      return null;
    }

    return this.create({
      _id: member._id,
      user: member.user,
      community: member.community,
      role: newRole,
      status: member.status,
      joinedAt: member.joinedAt,
    });
  },
};

module.exports =
  CommunityMemberFactory;