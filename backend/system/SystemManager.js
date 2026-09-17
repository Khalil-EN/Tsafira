const securityManager = require('./securityManager');

const UserService            = require('../services/user/UserService');
const CommunityService       = require('../services/community/CommunityService');
const CommunityMemberService = require('../services/community/communityMember/CommunityMemberService');
const PostService            = require('../services/feed/post/PostService');
const CommentService         = require('../services/feed/post/comment/CommentService');
const FeedService            = require('../services/feed/FeedService');
const FriendService          = require('../services/user/friend/FriendService');
const RequestService         = require('../services/request/RequestService');
const ChatService            = require('../services/chat/ChatService');
const SearchService          = require('../services/search/SearchService');
const ActivityService        = require('../services/activity/ActivityService');
const RestaurantService      = require('../services/restaurant/RestaurantService');
const ResidenceService       = require('../services/residence/ResidenceService');
const LocationService        = require('../services/location/LocationService');
const ItineraryService       = require('../services/itinerary/ItineraryService');
const PlanService            = require('../services/itinerary/plan/PlanService');
const NotificationService    = require('../services/infra/notification/NotificationService');
const AnalyticsService       = require('../services/infra/analytics/AnalyticsService');
const AIService = require("../services/ai/AIService");

class SystemManager {

  // ========================
  // 🔹 AUTH
  // ========================

  async registerUser(userData) {
    const user = await securityManager.register(userData);


    await securityManager.sendVerificationCode(
        user
    );

    return user;
  }
  async loginUser({ email, password, rememberMe }) { return await securityManager.login(email, password, rememberMe); }
  async logoutUser(refreshToken)                   { return await securityManager.logout(refreshToken); }
  async refreshToken(refreshToken)                 { return await securityManager.refreshToken(refreshToken); }
 
  async sendVerificationCode(email) {
    return await securityManager.sendVerificationCode(email);
  }

  async verifyEmail(email, code) {
      return await securityManager.verifyEmail(email, code);
  }

  async resendVerificationCode(email) {
      return await securityManager.resendVerificationCode(email);
  }

  // ========================
  // 🔹 USER
  // ========================

  async getCurrentUser(userId) {
    return await UserService.getUserById(userId);
  }

  async updateUser(userId, updates) {
    return await UserService.updateUser(userId, updates);
  }

  async getAllUsersByRole(role) {
    return await UserService.getAllUsersByRole(role);
  }

  async deactivateUser(userId) {
    const user = await UserService.deactivateUser(userId);

    this._log(`User deactivated: ${user.id}`);

    return user;
  }

  async saveFcmToken(userId, token) {
    return await UserService.saveFcmToken(userId, token);
  }

  async updateProfile(userId, updates) {
    console.log(userId);
    const user = await UserService.updateProfile(userId, updates);
    this._log(`User ${userId} updated their profile`);
    return user;
  }

  async deleteProfile(user) {
    const userId = user?.id ?? user?._id;

    // Order matters: remove this user's own posts (and every
    // comment on those posts, by anyone) first, then their
    // remaining comments on other people's posts, then their
    // memberships and friendships, then the account itself —
    // so nothing is left referencing a user that no longer exists.
    await PostService.deleteUserPosts(userId);
    await CommentService.deleteCommentsByAuthor(user);
    await PostService.removeLikesByUser(userId);
    await CommentService.removeLikesByUser(userId);
    await RequestService.deleteRequestsForUser(userId);
    await CommunityMemberService.removeAllMembershipsForUser(userId);
    await CommunityService.handleOwnedCommunitiesBeforeUserDeletion(userId);
    await ChatService.deleteDirectConversationsForUser(userId);
    await ChatService.deleteAIConversationForUser(userId);
    await UserService.removeFriendshipsForUser(userId);
    await UserService.deleteUser(userId);

    this._log(`User ${userId} deleted their account`);
  }

  // ========================
  // 🔹 SUGGESTIONS
  // ========================

  /**
   * Full cross-service coordination for itinerary suggestion:
   *
   *  1. Enforce quota          → UserService.checkSuggestionLimit
   *  2. Normalise raw inputs   → ActivityService.normalizeTypes
   *                              RestaurantService.cleanCuisineTypes
   *  3. Build request object   → ItineraryService.buildRequest (pure wrap, no service calls)
   *  4. Fetch all data in parallel:
   *       activities           → ActivityService.getAllActivities
   *       night activities     → ActivityService.getNightActivities
   *       restaurants          → RestaurantService.getAllRestaurants
   *       residencies          → ResidenceService.getRawResidences
   *  5. Build suggestion plan  → ItineraryService.buildSuggestion
   */
  async generateSuggestedItinerary(userId, rawPreferences) {
    await UserService.checkSuggestionLimit(userId);

    const normalisedPreferences = {
      ...rawPreferences,
      interests:      ActivityService.normalizeTypes(rawPreferences.interests      || []),
      restaurantTags: RestaurantService.cleanCuisineTypes(rawPreferences.restaurantTags || []),
    };

    const request = ItineraryService.buildRequest(normalisedPreferences);


    const [activities, nightActivities, restaurants, residencies] = await Promise.all([
                                                                        ActivityService.getActivitiesForPlanning(),
                                                                        ActivityService.getNightActivities(),
                                                                        RestaurantService.getRestaurantsForPlanning(),
                                                                        ResidenceService.getResidencesForPlanning(),
                                                                    ]);

    return ItineraryService.buildSuggestion(
      request, activities, restaurants, residencies, nightActivities
    );
  }

  // ========================
  // 🔹 ITINERARY
  // ========================

  async createItinerary(userId, data) {
    const itinerary = await ItineraryService.createItinerary({ ...data, userId });
    this._log(`New itinerary created: ${itinerary.title}`);
    return itinerary;
  }

  async getItineraryDetails(id)    { return await ItineraryService.getItineraryById(id); }
  async getUserItineraries(userId) { return await ItineraryService.getItinerariesByUser(userId); }

  async updateItinerary(id, updates) {
    const updated = await ItineraryService.updateItinerary(id, updates);
    this._log(`Itinerary updated: ${updated._id}`);
    return updated;
  }

  async deleteItinerary(id) {
    await ItineraryService.deleteItinerary(id);
    this._log(`Itinerary deleted: ${id}`);
  }

  // ========================
  // 🔹 PLAN
  // ========================

  async createPlanForItinerary(itineraryId, planInput) {
    const plan = await PlanService.createPlan({ ...planInput, itineraryId });
    this._log(`New plan added (day ${plan.dayNumber}) to itinerary ${itineraryId}`);
    return plan;
  }

  async getFullPlan(planId)               { return await PlanService.getPlanById(planId); }
  async getPlansForItinerary(itineraryId) { return await PlanService.getPlansByItinerary(itineraryId); }

  async updatePlan(planId, updates) {
    const updated = await PlanService.updatePlan(planId, updates);
    this._log(`Plan updated: ${planId}`);
    return updated;
  }

  async deletePlan(planId) {
    await PlanService.deletePlan(planId);
    this._log(`Plan deleted: ${planId}`);
  }

  // ========================
  // 🔹 RESIDENCE
  // ========================

  async addResidence(data) {
    const r = await ResidenceService.createResidence(data);
    this._log(`New residence added: ${r.name}`);
    return r;
  }

  async getResidence(id)             { return await ResidenceService.getResidenceById(id); }
  async getAllResidences()                { return await ResidenceService.listResidences(); }
  async searchResidences(filters)        { return await ResidenceService.search(filters); }
  async updateResidence(id, updates) { return await ResidenceService.updateResidence(id, updates); }
  async removeResidence(id)          { return await ResidenceService.deleteResidence(id); }

  // ========================
  // 🔹 RESTAURANT
  // ========================

  async addRestaurant(data) {
    const r = await RestaurantService.createRestaurant(data);
    this._log(`New restaurant added: ${r.name}`);
    return r;
  }

  async getRestaurant(id)             { return await RestaurantService.getRestaurantById(id); }
  async getAllRestaurants()            { return await RestaurantService.getAllRestaurants(); }
  async updateRestaurant(id, updates) { return await RestaurantService.updateRestaurant(id, updates); }
  async removeRestaurant(id)          { return await RestaurantService.deleteRestaurant(id); }

  async searchRestaurants(filters) {
    return await RestaurantService.search(
      RestaurantService.normalizeSearchFilters(filters)
    );
  }

  // ========================
  // 🔹 ACTIVITY
  // ========================

  async createActivity(data) {
    const a = await ActivityService.createActivity(data);
    this._log(`New activity created: ${a.name}`);
    return a;
  }

  async getActivity(id)             { return await ActivityService.getActivityById(id); }
  async getAllActivities()           { return await ActivityService.getAllActivities(); }
  async updateActivity(id, updates) { return await ActivityService.updateActivity(id, updates); }
  async deleteActivity(id)          { return await ActivityService.deleteActivity(id); }

  async searchActivities(filters) {
    return await ActivityService.search(
      ActivityService.normalizeSearchFilters(filters)
    );
  }

  // ========================
  // 🔹 LOCATION
  // ========================

  async addLocation(data)           { return await LocationService.createLocation(data); }
  async getLocation(id)             { return await LocationService.getLocationById(id); }
  async listLocations(filter = {})  { return await LocationService.getAllLocations(filter); }
  async updateLocation(id, updates) { return await LocationService.updateLocation(id, updates); }
  async removeLocation(id)          { return await LocationService.deleteLocation(id); }

  getDistanceBetween(lat1, lon1, lat2, lon2) {
    return LocationService.calculateDistance(lat1, lon1, lat2, lon2);
  }

   // ========================
  // 🔹 COMMUNITY
  // ========================

  async createCommunity(user, data)                { return await CommunityService.createCommunity(user, data); }
  async getCommunityById(id, userId) { return await CommunityService.getCommunityById(id, userId); }
  async getAllCommunities(filter = {})               { return await CommunityService.getAllCommunities(filter); }
  async updateCommunity(user, communityId, updates) { return await CommunityService.updateCommunity(communityId, updates, user); }
  async getCommunityMembers(communityId)             { return await CommunityMemberService.getCommunityMembers(communityId); }
  async requestToJoinCommunity(userId, communityId)  { return await CommunityMemberService.requestToJoin(userId, communityId); }

  async deleteCommunity(user, communityId) {
    await CommunityService.assertCanDeleteCommunity(communityId, user);


    await PostService.deletePostsByCommunity(communityId);

    await CommunityService.deleteCommunity(communityId, user);

    this._log(`Community ${communityId} deleted by user ${user.id}`);
  }

  async getPendingCommunityRequests(communityId, actingUser) {
    const actingUserId =
      actingUser?.id ??
      actingUser?._id ??
      actingUser;

    return await CommunityMemberService.getPendingMembers(
      communityId,
      actingUserId
    );
  }

  async approveCommunityMember(admin, communityId, userId) {
    const adminId =
      admin?.id ??
      admin?._id ??
      admin;

    const member =
      await CommunityMemberService.approveMember(
        communityId,
        userId,
        adminId
      );

    this._log(
      `User ${userId} approved in community ${communityId}`
    );

    return member;
  }

  async rejectCommunityMember(admin, communityId, userId) {
    const adminId =
      admin?.id ??
      admin?._id ??
      admin;

    await CommunityMemberService.rejectMember(
      communityId,
      userId,
      adminId
    );

    this._log(
      `User ${userId} rejected from community ${communityId}`
    );
  }

  async promoteCommunityMember(admin, communityId, userId, role) {
    const adminId =
      admin?.id ??
      admin?._id ??
      admin;

    const member =
      await CommunityMemberService.promoteMember(
        communityId,
        userId,
        role,
        adminId
      );

    this._log(
      `User ${userId} promoted to ${role} in community ${communityId}`
    );

    return member;
  }

  async banCommunityMember(admin, communityId, userId) {
    const adminId =
      admin?.id ??
      admin?._id ??
      admin;

    const member =
      await CommunityMemberService.banMember(
        communityId,
        userId,
        adminId
      );

    this._log(
      `User ${userId} banned from community ${communityId} by ${adminId}`
    );

    return member;
  }

  async getMyMemberships(userId) {
    return await CommunityMemberService.getUserMemberships(userId);
  }

  // ========================
  // 🔹 POSTS
  // ========================

  async createPost(user, postData) {
    await CommunityService.assertUserCanPost(user.id, postData.visibility, postData.community);
    const post = await PostService.createPost(user, postData);
    this._log(`New post by ${user.id} in community ${post.community}`);
    AnalyticsService.log('create_post', { userId: user.id });
    return post;
  }

  async getPostById(user, postId) {

    const [
      friendIds,
      communityIds,
    ] = await Promise.all([
      FriendService.getFriendIds(user.id),
      UserService.getUserCommunityIds(user.id),
    ]);

    return await PostService.getPostById(
      user,
      postId,
      friendIds,
      communityIds
    );
  }

 async likePost(user, postId) {

    const [
      friendIds,
      communityIds,
    ] = await Promise.all([
      FriendService.getFriendIds(user.id),
      UserService.getUserCommunityIds(user.id),
    ]);

    const post = await PostService.likePost(
      user,
      postId,
      friendIds,
      communityIds
    );

    this._log(
      `User ${user.id} toggled like on post ${postId}`
    );

    AnalyticsService.log(
      "like_post",
      {
        userId: user.id,
        properties: {
          postId,
          liked: post.liked,
        },
      }
    );

    return post;
  }

    async updatePost(user, postId, updates) {
    const post = await PostService.updatePost(user, postId, updates);
    this._log(`Post ${postId} updated by user ${user.id}`);
    return post;
  }

  async deletePost(user, postId) {
    await PostService.deletePost(user, postId);
    this._log(`Post ${postId} deleted by user ${user.id}`);
  }

  async getFeed(userId, options = {}) {
    AnalyticsService.log('view_feed', { userId });
    return await FeedService.getUserFeed(userId, options);
  }

  async getCommunityFeed(user, communityId, options = {}) {
    await CommunityService.assertUserIsMember(user.id, communityId);
    return await PostService.getCommunityFeed(user.id, communityId, options);
  }

  // ========================
  // 🔹 COMMENTS
  // ========================

  async addComment(user, commentData) {
    const comment = await CommentService.addComment(user, commentData);
    this._log(`New comment by ${user.id} on post ${comment.post}`);
    AnalyticsService.log('add_comment', { userId: user.id });
    return comment;
  }

  async getCommentsByPost(user, postId) {

    const [
      friendIds,
      communityIds,
    ] = await Promise.all([
      FriendService.getFriendIds(user.id),
      UserService.getUserCommunityIds(user.id),
    ]);

    await PostService.assertCanView(user.id, postId, friendIds, communityIds);

    return await CommentService.getCommentsByPost(postId, user.id);
  }
  async deleteComment(user, commentId) { return await CommentService.deleteComment(user, commentId); }

  async likeComment(user, commentId) {

    const [
      friendIds,
      communityIds,
    ] = await Promise.all([
      FriendService.getFriendIds(user.id),
      UserService.getUserCommunityIds(user.id),
    ]);

    const comment = await CommentService.likeComment(user, commentId);

    this._log(
        `User ${user.id} toggled like on comment ${commentId}`
    );

    AnalyticsService.log(
        "like_comment",
        {
            userId: user.id,
            properties: {
                commentId,
                liked: comment.liked,
            },
        }
    );

    return comment;
  }

  async updateComment(user, commentId, text) {
    const comment = await CommentService.updateComment(user, commentId, text);
    this._log(`Comment ${commentId} updated by user ${user.id}`);
    return comment;
  }

  // ========================
  // 🔹 FEED
  // ========================

  async getFeed(userId, options = {}) {
    AnalyticsService.log('view_feed', { userId });
    return await FeedService.getUserFeed(userId, options);
  }

  // ========================
  // 🔹 FRIENDS & REQUESTS
  // ========================

  async getFriends(userId) {
    return await FriendService.getFriends(userId);
  }

  async sendFriendRequest(userId, targetUserId) {
    const request = await FriendService.sendFriendRequest(userId, targetUserId);

    await NotificationService.send({
      recipientId: targetUserId,
      type:        'friend_request',
      title:       'New Friend Request',
      body:        'Someone wants to be your friend.',
      refModel:    'Request',
      refId:       request._id,
    });

    AnalyticsService.log('send_friend_request', { userId });
    return request;
  }

  async getRequests(userId) { return await RequestService.getRequests(userId); }

  async acceptRequest(requestId, actingUserId) {
    const request = await RequestService.acceptRequest(requestId);

    const isFriend = request.type === "friend";

    await NotificationService.send({
        recipientId: request.sender._id,
        type: isFriend
            ? "friend_accepted"
            : "community_accepted",

        title: isFriend
            ? "Friend Request Accepted"
            : "Community Request Accepted",

        body: isFriend
            ? "Your friend request was accepted!"
            : `You are now a member of ${
                request.community?.name || "the community"
            }.`,

        refModel: isFriend ? "User" : "Community",

        refId: isFriend
            ? request.recipient._id
            : request.community?._id,
    });

    if (
        actingUserId &&
        /^[a-f\d]{24}$/i.test(actingUserId.toString())
    ) {
        AnalyticsService.log("accept_request", {
            userId: actingUserId,
        });
    }
  }

  async rejectRequest(requestId, actingUserId) {
    await RequestService.rejectRequest(requestId);
    if (actingUserId && /^[a-f\d]{24}$/i.test(actingUserId.toString())) {
      AnalyticsService.log('reject_request', { userId: actingUserId });
    }
  }

  // ========================
  // 🔹 CHAT
  // ========================

  async getInbox(userId, page = 1, limit = 20) {
    return await ChatService.getInbox(userId, page, limit);
  }

  async getMessages(userId, conversationId, page = 1, limit = 30) {
      return await ChatService.getMessages(
          userId,
          conversationId,
          page,
          limit
      );
  }

  async sendMessage(senderId, conversationId, content) {
      return await ChatService.sendMessage(
          senderId,
          conversationId,
          content
      );
  }

  async getOrCreateDirectChat(userId, participantId) {
      return await ChatService.getOrCreateDirectChat(
          userId,
          participantId
      );
  }

  async markConversationAsRead(userId, conversationId){
    return await ChatService.markConversationAsRead(userId, conversationId);
  }

  async getOrCreateAIConversation(
    userId
  ) {
    return await AIService
      .getOrCreateConversation(
        userId
      );
  }


  async sendAIMessage(
    userId,
    conversationId,
    content
  ) {
    return await AIService
      .sendMessage(
        userId,
        conversationId,
        content
      );
  }

  // ========================
  // 🔹 SEARCH
  // ========================

  async searchUsersAndCommunities(userId, query, types = []) {
    AnalyticsService.log('search', { userId, properties: { query, types } });
    return await SearchService.searchUsersAndCommunities(userId, query, types);
  }

  // ========================
  // 🔹 NOTIFICATIONS
  // ========================

  async getNotifications(userId, opts) {
    const NotificationDAO = require('../dao/notificationDAO');
    return await NotificationDAO.getForUser(userId, opts);
  }

  async getUnreadNotificationCount(userId) {
    const NotificationDAO = require('../dao/notificationDAO');
    return await NotificationDAO.getUnreadCount(userId);
  }

  async markNotificationRead(notificationId, userId) {
    const NotificationDAO = require('../dao/notificationDAO');
    return await NotificationDAO.markRead(notificationId, userId);
  }

  async markAllNotificationsRead(userId) {
    const NotificationDAO = require('../dao/notificationDAO');
    return await NotificationDAO.markAllRead(userId);
  }

  // ========================
  // ADMIN — USERS
  // ========================

  async getAllUsers({ page = 1, limit = 20 } = {}) {
    return UserService.getAllUsers({
      page,
      limit,
    });
  }

  async banUser(adminId, targetUserId) {
    const user = await UserService.banUser(targetUserId);

    this._log(
      `Admin ${adminId} banned user ${targetUserId}`
    );

    AnalyticsService.log("admin_ban_user", {
      userId: adminId,
      properties: {
        targetUserId,
      },
    });

    return user;
  }

  async unbanUser(adminId, targetUserId) {
    const user = await UserService.unbanUser(targetUserId);

    this._log(
      `Admin ${adminId} unbanned user ${targetUserId}`
    );

    AnalyticsService.log("admin_unban_user", {
      userId: adminId,
      properties: {
        targetUserId,
      },
    });

    return user;
  }


  // ========================
  // ADMIN — CONTENT
  // ========================

  async adminDeletePost(adminId, postId) {
    await PostService.deletePost(
      {
        id: adminId,
        role: 'admin',
      },
      postId
    );

    this._log(
      `Admin ${adminId} deleted post ${postId}`
    );

    AnalyticsService.log('admin_delete_post', {
      userId: adminId,
      properties: { postId },
    });
  }


  // ========================
  // ADMIN — ANALYTICS
  // ========================

  async getAnalyticsEventCounts(filters = {}) {
    return AnalyticsService.getEventCounts(filters);
  }

  async getAnalyticsDailyActiveUsers(filters = {}) {
    return AnalyticsService.getDailyActiveUsers(filters);
  }

  async getAnalyticsRecentEvents(filters = {}) {
    return AnalyticsService.getRecentEvents(filters);
  }


  // ========================
  // ADMIN — BROADCAST
  // ========================

  async sendSystemNotification(
    adminId,
    { recipientIds, title, body }
  ) {
    let ids = recipientIds;

    if (recipientIds === "all") {
      ids = await UserService.getAllUserIds();
    }

    if (!ids || ids.length === 0) {
      return 0;
    }

    await NotificationService.sendToMany({
      recipientIds: ids,
      type: "system",
      title,
      body,
    });

    this._log(
      `Admin ${adminId} broadcast notification to ${ids.length} users`
    );

    AnalyticsService.log("admin_send_notification", {
      userId: adminId,
      properties: {
        recipientCount: ids.length,
      },
    });

    return ids.length;
  }

  // ========================
  // 🔹 INTERNAL
  // ========================

  _log(msg) { console.log(`[SystemManager] ${msg}`); }
}

module.exports = new SystemManager();