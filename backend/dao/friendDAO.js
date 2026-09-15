const UserModel = require("../schemas/userSchema");

const FriendDAO = {
  async getFriends(userId) {
    const user = await UserModel.findById(userId)
      .select("friends")
      .lean();

    return user?.friends || [];
  },
};

module.exports = FriendDAO;
