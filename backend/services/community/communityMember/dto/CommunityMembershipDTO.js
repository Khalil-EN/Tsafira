class CommunityMembershipDTO {
    constructor({
        id,
        communityId,
        name,
        coverImage = null,
        privacy = null,
        role,
        status = "active",
        joinedAt = null,
    }) {
        this.id = id;
        this.communityId = communityId;
        this.name = name;
        this.coverImage = coverImage;
        this.privacy = privacy;
        this.role = role;
        this.status = status;
        this.joinedAt = joinedAt;

        Object.freeze(this);
    }
}

module.exports = CommunityMembershipDTO;