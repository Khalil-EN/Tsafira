const CommunityDTO = require("./dto/CommunityDTO");
const CommunitySearchResultDTO = require(
  "./dto/CommunitySearchResultDTO"
);
const CommunityDetailDTO = require("./dto/CommunityDetailDTO");


const CommunityAssembler = {
    toDTO(community) {
        if (!community) {
            return null;
        }

        return new CommunityDTO({
            id: community.id?.toString() ?? null,
            name: community.name,
            description: community.description ?? "",
            creator: community.creator?.toString() ?? null,
            owner: community.owner?.toString() ?? null,
            privacy: community.privacy ?? null,
            membersCount: community.membersCount ?? 0,
            postsCount: community.postsCount ?? 0,
            createdAt: community.createdAt ?? null,
        });
    },

    toDTOList(communities = []) {
        return communities
            .map(community => this.toDTO(community))
            .filter(Boolean);
    },

    toDetailDTO(community, membership = null) {
        if (!community) {
            return null;
        }

        return new CommunityDetailDTO({
            community: this.toDTO(community),
            viewerRole: membership?.role ?? null,
            viewerStatus: membership?.status ?? null,
        });
    },

    toSearchResult(
        community,
        userId,
        membershipInfo = {}
    ) {
        if (!community) {
            return null;
        }

        const communityId =
            community._id?.toString() ??
            community.id?.toString() ??
            null;

        return new CommunitySearchResultDTO({
            id: communityId,
            type: "community",
            name: community.name,
            description: community.description ?? null,
            privacy: community.privacy ?? null,
            isMember: membershipInfo.isMember === true,
            requestSent: membershipInfo.requestSent === true,
        });
    },
};

module.exports = CommunityAssembler;