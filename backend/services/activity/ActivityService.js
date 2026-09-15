const activityDAO = require('../../dao/activityDAO');

const Activity =
    require('../../domain/activities/BasicActivity');

const ActivityTypeEnum =
    require('../../domain/activities/enums/ActivityTypeEnum');

const ActivityAssembler =
    require('./ActivityAssembler');

const ActivityMapper =
  require('./ActivityMapper');


const ActivityService = {

    async createActivity(data) {

        const doc =
            await activityDAO.create(data);

        const activity =
            new Activity(doc);

        return ActivityAssembler.toDTO(activity);
    },

    async getActivityById(id) {

        const doc =
            await activityDAO.getById(id);

        if (!doc) {
            return null;
        }

        const activity =
            new Activity(doc);

        return ActivityAssembler.toDTO(activity);
    },

    async updateActivity(id, updates) {

        const doc =
            await activityDAO.update(
                id,
                updates
            );

        if (!doc) {
            return null;
        }

        const activity =
            new Activity(doc);

        return ActivityAssembler.toDTO(activity);
    },

    async deleteActivity(id) {

        return await activityDAO.delete(id);
    },


    async getAllActivities(filters = {}) {

        const docs =
            await activityDAO.getAll(filters);

        const activities =
            docs.map(
                doc => new Activity(doc)
            );

        return ActivityAssembler.toDTOList(
            activities
        );
    },

    async getActivitiesForPlanning(filters = {}) {
        const docs =
            await activityDAO.getAll(filters);

        return docs
            .map(doc =>
            ActivityMapper.fromPersistence(doc)
            )
            .filter(Boolean);
        },


    async getNightActivities() {

        // TODO:
        // Replace this with:
        //
        // return activityDAO.getByTypes([
        //     ActivityTypeEnum.NIGHTLIFE,
        //     ActivityTypeEnum.MUSIC,
        //     ActivityTypeEnum.CINEMA,
        //     ActivityTypeEnum.CRUISE,
        //     ActivityTypeEnum.MARKET,
        // ]);

        return [
            {
                name: 'Sky Lounge Bar',
                activitytype:
                    ActivityTypeEnum.NIGHTLIFE,
                numberofreviews: 230,
                rating: 4.6,
                image:
                    'https://example.com/images/sky-lounge.jpg',
                latitude: 40.7561,
                longitude: -73.9864,
            },

            {
                name: 'Jazz & Blues Club',
                activitytype:
                    ActivityTypeEnum.MUSIC,
                numberofreviews: 180,
                rating: 4.8,
                image:
                    'https://example.com/images/jazz-blues.jpg',
                latitude: 40.7401,
                longitude: -73.9947,
            },

            {
                name: 'Moonlight Cinema',
                activitytype:
                    ActivityTypeEnum.CINEMA,
                numberofreviews: 95,
                rating: 4.4,
                image:
                    'https://example.com/images/moonlight-cinema.jpg',
                latitude: 40.7333,
                longitude: -73.9872,
            },

            {
                name: 'Night River Cruise',
                activitytype:
                    ActivityTypeEnum.CRUISE,
                numberofreviews: 120,
                rating: 4.7,
                image:
                    'https://example.com/images/night-cruise.jpg',
                latitude: 40.7032,
                longitude: -74.0170,
            },

            {
                name: 'Night Market Walk',
                activitytype:
                    ActivityTypeEnum.MARKET,
                numberofreviews: 75,
                rating: 4.3,
                image:
                    'https://example.com/images/night-market.jpg',
                latitude: 40.7429,
                longitude: -74.0048,
            },
        ];
    },

    async search(filters) {

        const docs =
            await activityDAO.search(filters);

        const activities =
            docs.map(
                doc => new Activity(doc)
            );

        return ActivityAssembler.toDTOList(
            activities
        );
    },

    normalizeTypes(activityTypes) {

        return Activity.normalizeTypes(
            activityTypes
        );
    },


    normalizeSearchFilters(filters) {

        if (filters.activityTypes) {

            filters.activityTypes =
                Activity.normalizeTypes(
                    filters.activityTypes
                );
        }

        return filters;
    },

};

module.exports = ActivityService;