const Community = require("./community");

class CommunityFactory {

  static create(data) {
    if (!data) {
      return null;
    }

    return new Community({
      id: data.id ?? null,
      name: data.name,
      description: data.description ?? "",
      creator: data.creator ?? null,
      owner: data.owner ?? data.creator ?? null,
      privacy: data.privacy ?? "public",
      membersCount: data.membersCount ?? 0,
      postsCount: data.postsCount ?? 0,
      isActive: data.isActive ?? true,
      createdAt: data.createdAt ?? null,
    });
  }

}

module.exports = CommunityFactory;