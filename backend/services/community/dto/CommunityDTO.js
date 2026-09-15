class CommunityDTO {
    constructor({
        id,
        name,
        description,
        creator = null,
        owner = null,
        privacy = null,
        membersCount = 0,
        postsCount = 0,
        createdAt = null,
    }) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.creator = creator;
        this.owner = owner;
        this.privacy = privacy;
        this.membersCount = membersCount;
        this.postsCount = postsCount;
        this.createdAt = createdAt;

        Object.freeze(this);
    }
}

module.exports = CommunityDTO;