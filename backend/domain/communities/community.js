class Community {
  constructor({
    id,
    name,
    description = "",
    creator,
    owner,
    privacy = "public",
    membersCount = 0,
    postsCount = 0,
    isActive = true,
    createdAt = null,
  }) {
    this.id = id;
    this.name = name;
    this.description = description;
    this.creator = creator;
    this.owner = owner;
    this.privacy = privacy;
    this.membersCount = membersCount || 0;
    this.postsCount = postsCount || 0;
    this.isActive = isActive;
    this.createdAt = createdAt;
  }

  isPublic() {
    return this.privacy === "public";
  }

  isPrivate() {
    return this.privacy === "private";
  }

  incrementMembers() {
    this.membersCount++;
  }

  decrementMembers() {
    if (this.membersCount > 0) {
      this.membersCount--;
    }
  }

  incrementPosts() {
    this.postsCount++;
  }

  decrementPosts() {
    if (this.postsCount > 0) {
      this.postsCount--;
    }
  }

  toJSON() {
    return {
      id: this.id,
      name: this.name,
      description: this.description,
      creator: this.creator,
      owner: this.owner,
      privacy: this.privacy,
      membersCount: this.membersCount,
      postsCount: this.postsCount,
      isActive: this.isActive,
      createdAt: this.createdAt,
    };
  }
}

module.exports = Community;