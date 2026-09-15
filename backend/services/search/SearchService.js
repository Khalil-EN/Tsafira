const FriendService = require('../user/friend/FriendService');
const CommunityService = require('../community/CommunityService');

/**
 * Maps each searchable type to its handler.
 * Adding a new searchable entity means adding one entry here — no branching logic to touch.
 */
const SEARCH_HANDLERS = {
  user:      (userId, query) => FriendService.searchUsers(userId, query),
  community: (userId, query) => CommunityService.searchCommunities(userId, query),
};

const SearchService = {
  /**
   * Searches across one or more entity types.
   * @param {string} userId
   * @param {string} query
   * @param {string[]} types - subset of SEARCH_HANDLERS keys; empty means search all
   */
  async searchUsersAndCommunities(userId, query, types = []) {
    const activeTypes = types.length > 0
      ? types.filter(t => SEARCH_HANDLERS[t])     // ignore unknown types gracefully
      : Object.keys(SEARCH_HANDLERS);             // empty = search all

    const results = await Promise.all(
      activeTypes.map(type => SEARCH_HANDLERS[type](userId, query))
    );

    return results.flat();
  },
};

module.exports = SearchService;