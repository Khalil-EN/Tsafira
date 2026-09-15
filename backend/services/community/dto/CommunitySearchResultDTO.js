class CommunitySearchResultDTO {
    constructor({
        id,
        type = 'community',
        name,
        description = null,
        coverImage = null,
        privacy = null,
        isMember = false,
        requestSent = false,
    }) {
        this.id = id;
        this.type = type;
        this.name = name;
        this.description = description;
        this.coverImage = coverImage;
        this.privacy = privacy;
        this.isMember = isMember;
        this.requestSent = requestSent;

        Object.freeze(this);
    }
}

module.exports = CommunitySearchResultDTO;