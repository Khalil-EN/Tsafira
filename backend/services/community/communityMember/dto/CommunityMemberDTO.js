class CommunityMemberDTO {
    constructor({
        id,
        user,
        communityId,
        role,
        status,
    }) {
        this.id = id;
        this.user = user;
        this.communityId = communityId;
        this.role = role;
        this.status = status;

        Object.freeze(this);
    }
}

module.exports = CommunityMemberDTO;