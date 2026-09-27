const FriendService = require('../user/friend/FriendService');
const CommunityService = require('../community/CommunityService');

const SEARCH_HANDLERS = {
  user:      (userId, query) => FriendService.searchUsers(userId, query),
  community: (userId, query) => CommunityService.searchCommunities(userId, query),
};

const SearchService = {
  /**
   * @param {string} userId
   * @param {string} query
   * @param {string[]} types 
   */

  async searchUsersAndCommunities(userId, query, types = []) {

    const activeTypes = types.length > 0 ? types.filter(t => SEARCH_HANDLERS[t]) : Object.keys(SEARCH_HANDLERS);  

    const results = await Promise.all(activeTypes.map(type => SEARCH_HANDLERS[type](userId, query)));

    return results.flat();
  },
};

module.exports = SearchService;