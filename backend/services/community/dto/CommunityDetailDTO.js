class CommunityDetailDTO {
    constructor({
        community,
        viewerRole = null,
        viewerStatus = null,
    }) {
        this.community = community;
        this.viewerRole = viewerRole;
        this.viewerStatus = viewerStatus;

        Object.freeze(this);
    }
}

module.exports = CommunityDetailDTO;