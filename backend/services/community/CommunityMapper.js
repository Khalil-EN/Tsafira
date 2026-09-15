const CommunityFactory = require(
  "../../domain/communities/communityFactory"
);

const CommunityMapper = {
  /**
   * Convert MongoDB persistence data into
   * normalized data and then construct the
   * Community domain object through the factory.
   */
  fromPersistence(data) {
    if (!data) {
      return null;
    }

    return CommunityFactory.create({
      id:
        data._id?.toString() ??
        data.id?.toString() ??
        null,

      name:
        data.name ?? "",

      description:
        data.description ?? "",

      creator:
        data.creator?._id?.toString() ??
        data.creator?.id?.toString() ??
        data.creator?.toString() ??
        null,

      owner:
        data.owner?._id?.toString() ??
        data.owner?.id?.toString() ??
        data.owner?.toString() ??
        data.creator?._id?.toString() ??
        data.creator?.id?.toString() ??
        data.creator?.toString() ??
        null,

      privacy:
        data.privacy ?? "public",

      membersCount:
        Number(data.membersCount) || 0,

      postsCount:
        Number(data.postsCount) || 0,

      isActive:
        data.isActive !== false,

      createdAt:
        data.createdAt ?? null,
    });
  },

  /**
   * Convert a list of persistence documents
   * into Community domain objects.
   */
  fromPersistenceList(data = []) {
    return data
      .map(item => this.fromPersistence(item))
      .filter(Boolean);
  },

  /**
   * Convert a Community domain object into
   * persistence-ready data.
   *
   * Membership is deliberately NOT included.
   * CommunityMember owns membership persistence.
   */
  toPersistence(community) {
    if (!community) {
      return null;
    }

    return {
      name: community.name,
      description: community.description,
      creator: community.creator,
      owner: community.owner,
      privacy: community.privacy,
      membersCount: community.membersCount,
      postsCount: community.postsCount,
      isActive: community.isActive,
      createdAt: community.createdAt,
    };
  },
};

module.exports = CommunityMapper;