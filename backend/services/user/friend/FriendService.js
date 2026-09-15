const UserDAO = require('../../../dao/userDAO');
const RequestDAO = require('../../../dao/requestDAO');

const FriendService = {

  // ─────────────────────────────────────────────────────────────
  // Internal
  // ─────────────────────────────────────────────────────────────

  async _getUser(userId) {
    return await UserDAO.getUserById(userId);
  },

  // ─────────────────────────────────────────────────────────────
  // Friends
  // ─────────────────────────────────────────────────────────────

  async getFriendIds(userId) {
    const user = await FriendService._getUser(userId);
    return user?.friends || [];
  },

  async getFriends(userId) {
    const friendIds = await FriendService.getFriendIds(userId);

    if (!friendIds.length) {
      return [];
    }

    const friends = await UserDAO.getUsersByIds(
      friendIds,
      {
        firstName: 1,
        lastName: 1,
        profilePicture: 1,
        email: 1,
      }
    );

    return friends.map(f => ({
      id: f._id,
      firstName: f.firstName,
      lastName: f.lastName,
      fullName: `${f.firstName} ${f.lastName}`,
      profilePicture: f.profilePicture || null,
      email: f.email,
    }));
  },

  // ─────────────────────────────────────────────────────────────
  // Search
  // ─────────────────────────────────────────────────────────────

  async searchUsers(userId, query) {
    const [users, currentUser] = await Promise.all([
      UserDAO.searchUsers(query, userId),
      FriendService._getUser(userId),
    ]);

    const friendIds = new Set(
      (currentUser?.friends || []).map(
        id => id.toString()
      )
    );

    const userIds = users.map(
      user => user._id
    );

    const pendingRequests =
      await RequestDAO.getPendingFriendRequestsSentTo(
        userId,
        userIds
      );

    const pendingRecipientIds = new Set(
      pendingRequests.map(
        request =>
          request.recipient.toString()
      )
    );

    return users.map(user => {
      const userIdString =
        user._id.toString();

      return {
        id: userIdString,
        type: 'user',
        name:
          `${user.firstName ?? ''} ${user.lastName ?? ''}`
            .trim(),
        profilePicture:
          user.profilePicture ?? null,
        isFriend:
          friendIds.has(userIdString),
        requestSent:
          pendingRecipientIds.has(
            userIdString
          ),
      };
    });
  },

  // ─────────────────────────────────────────────────────────────
  // Friend requests
  // ─────────────────────────────────────────────────────────────

  async sendFriendRequest(fromUserId, toUserId) {
    if (fromUserId.toString() === toUserId.toString()) {
      throw new Error('You cannot send a friend request to yourself');
    }

    const existing = await RequestDAO.findPendingRequest(
      fromUserId,
      toUserId,
      'friend'
    );

    if (existing) {
      throw new Error(
        'A pending friend request already exists'
      );
    }

    return await RequestDAO.create({
      sender: fromUserId,
      recipient: toUserId,
      type: 'friend',
      status: 'pending',
    });
  },

  async addFriend(
    userId,
    friendId
  ) {
    if (
      !userId ||
      !friendId
    ) {
      throw new Error(
        "Both user IDs are required."
      );
    }

    if (
      userId.toString() ===
      friendId.toString()
    ) {
      throw new Error(
        "A user cannot be friends with themselves."
      );
    }

    const [
      user,
      friend,
    ] = await Promise.all([
      FriendService._getUser(userId),
      FriendService._getUser(friendId),
    ]);

    if (!user) {
      throw new Error(
        "User not found."
      );
    }

    if (!friend) {
      throw new Error(
        "Friend user not found."
      );
    }

    /*
     * $addToSet makes this operation idempotent:
     * adding an existing friend does not create
     * duplicate IDs.
     */
    await UserDAO.addFriend(
      userId,
      friendId
    );
  },
};

module.exports = FriendService;