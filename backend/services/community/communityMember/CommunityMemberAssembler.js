const CommunityMemberDTO = require(
    "./dto/CommunityMemberDTO"
);

const CommunityMembershipDTO = require(
    "./dto/CommunityMembershipDTO"
);

const UserSummaryDTO = require(
    "../../user/dto/UserSummaryDTO"
);

class CommunityMemberAssembler {

    static toUserSummary(user) {
        if (!user) {
            return null;
        }

        return new UserSummaryDTO({
            id:
                user._id?.toString() ??
                user.id?.toString() ??
                null,

            firstName:
                user.firstName ?? "",

            lastName:
                user.lastName ?? "",

            email:
                user.email ?? null,

            profilePicture:
                user.profilePicture ?? null,
        });
    }

    static toDTO(member) {
        if (!member) {
            return null;
        }

        return new CommunityMemberDTO({
            id:
                member._id?.toString() ??
                member.id?.toString() ??
                null,

            user:
                this.toUserSummary(member.user),

            communityId:
                member.community?._id?.toString() ??
                member.community?.id?.toString() ??
                member.community?.toString() ??
                member.communityId?.toString() ??
                null,

            role:
                member.role ?? "member",

            status:
                member.status ?? "active",
        });
    }

    static toDTOs(members = []) {
        return members
            .map(member => this.toDTO(member))
            .filter(Boolean);
    }

    static toMembershipDTO(membership) {
        if (!membership) {
            return null;
        }

        const community = membership.community;

        return new CommunityMembershipDTO({
            id:
                membership._id?.toString() ??
                membership.id?.toString() ??
                null,

            communityId:
                community?._id?.toString() ??
                community?.id?.toString() ??
                membership.community?.toString() ??
                null,

            name:
                community?.name ??
                "Unknown",

            role:
                membership.role ??
                "member",

            status:
                membership.status ??
                "active",

            joinedAt:
                membership.joinedAt ??
                null,
        });
    }

    static toMembershipDTOs(memberships = []) {
        return memberships
            .map(membership =>
                this.toMembershipDTO(membership)
            )
            .filter(Boolean);
    }
}

module.exports = CommunityMemberAssembler;