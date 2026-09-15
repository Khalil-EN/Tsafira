const systemManager =
    require("../../../system/SystemManager");

const CommunityController = {

    async createCommunity(req, res) {

        const {
            name,
            description,
        } = req.body;

        const community =
            await systemManager.createCommunity(
                req.user,
                {
                    name,
                    description,
                },
            );

        return res.status(201).json({
            success: true,
            data: community,
        });
    },

    async getAllCommunities(req, res) {

        const communities =
            await systemManager.getAllCommunities();

        return res.status(200).json({
            success: true,
            data: communities,
        });
    },

    async getCommunityById(req, res) {
        const community = await systemManager.getCommunityById(
            req.params.id,
            req.user?.id 
        );

        return res.status(200).json({
            success: true,
            data: community,
        });
    },

    async updateCommunity(req, res) {

        const community =
            await systemManager.updateCommunity(
                req.user,
                req.params.id,
                req.body
            );

        return res.status(200).json({
            success: true,
            data: community,
        });
    },

    async deleteCommunity(req, res) {

        await systemManager.deleteCommunity(
            req.user,
            req.params.id
        );

        return res.status(200).json({
            success: true,
            data: {
                message:
                    "Community deleted successfully.",
            },
        });
    },

    async getCommunityFeed(req, res) {
        const posts = await systemManager.getCommunityFeed(
            req.user,
            req.params.id,
            req.query
        );
    
        return res.status(200).json({
            success: true,
            data: posts,
        });
      },

    async joinCommunity(req, res) {

        await systemManager.requestToJoinCommunity(
            req.user.id,
            req.params.id
        );

        return res.status(200).json({
            success: true,
            data: {
                message: "Join request sent.",
            },
        });
    },

    async getMembers(req, res) {

        const members =
            await systemManager.getCommunityMembers(
                req.params.id
            );

        return res.status(200).json({
            success: true,
            data: members,
        });
    },

    async approveMember(req, res) {

        await systemManager.approveCommunityMember(
            req.user,
            req.params.id,
            req.params.userId
        );

        return res.status(200).json({
            success: true,
            data: {
                message: "Member approved.",
            },
        });
    },

    async getMyMemberships(req, res) {

        const memberships =
            await systemManager.getMyMemberships(
                req.user.id
            );

        return res.status(200).json({
            success: true,
            data: memberships,
        });
    },

    async getPendingRequests(req, res) {
        const requests = await systemManager.getPendingCommunityRequests(
            req.params.id,
            req.user.id
        );

        return res.status(200).json({
            success: true,
            data: requests,
        });
        },

        async rejectMember(req, res) {
        await systemManager.rejectCommunityMember(
            req.params.id,
            req.params.userId,
            req.user.id
        );

        return res.status(200).json({
            success: true,
            data: {
            message: "Member request rejected.",
            },
        });
    },

    async promoteMember(req, res) {
        const member = await systemManager.promoteCommunityMember(
            req.user,
            req.params.id,
            req.params.userId,
            req.body.role
        );

        return res.status(200).json({
            success: true,
            data: member,
        });
    },

    async banMember(req, res) {
        const member = await systemManager.banCommunityMember(
            req.user,
            req.params.id,
            req.params.userId
        );

        return res.status(200).json({
            success: true,
            data: member,
        });
    },

};

module.exports = CommunityController;