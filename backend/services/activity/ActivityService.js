const activityDAO = require("../../dao/activityDAO");
const Activity = require("../../domain/activities/BasicActivity");
const ActivityAssembler = require("./ActivityAssembler");
const ActivityMapper = require("./ActivityMapper");

const NightActivityLoader = require("../../loaders/NightActivityLoader");
const NightActivityMapper = require("./NightActivityMapper");

const ActivityService = {

    async createActivity(data) {
        const doc = await activityDAO.create(data);

        const activity = ActivityMapper.fromPersistence(doc);

        return ActivityAssembler.toDTO(activity);
    },

    async getActivityById(id) {
        const doc = await activityDAO.getById(id);

        if (!doc) {
            return null;
        }

        const activity = ActivityMapper.fromPersistence(doc);

        return ActivityAssembler.toDTO(activity);
    },

    async updateActivity(id, updates) {
        const doc = await activityDAO.update(id, updates);

        if (!doc) {
            return null;
        }

        const activity = ActivityMapper.fromPersistence(doc);

        return ActivityAssembler.toDTO(activity);
    },

    async deleteActivity(id) {
        return await activityDAO.delete(id);
    },

    async getAllActivities(filters = {}) {
        const docs = await activityDAO.getAll(filters);

        const activities = docs
            .map(doc => ActivityMapper.fromPersistence(doc))
            .filter(Boolean);

        return ActivityAssembler.toDTOList(activities);
    },

    async getActivitiesForPlanning(filters = {}) {
        const docs = await activityDAO.getAll(filters);

        return docs
            .map(doc => ActivityMapper.fromPersistence(doc))
            .filter(Boolean);
    },

    async getNightActivities() {
        const data = await NightActivityLoader.load();

        const activities = data
            .map(activityData => NightActivityMapper.fromExternal(activityData))
            .filter(Boolean);

        return ActivityAssembler.toDTOList(activities);
    },

    async search(filters) {
        const docs = await activityDAO.search(filters);

        const activities = docs
            .map(doc => ActivityMapper.fromPersistence(doc))
            .filter(Boolean);

        return ActivityAssembler.toDTOList(activities);
    },

    normalizeTypes(activityTypes) {
        return Activity.normalizeTypes(activityTypes);
    },

    normalizeSearchFilters(filters) {
        if (filters.activityTypes) {
            filters.activityTypes =
                Activity.normalizeTypes(filters.activityTypes);
        }

        return filters;
    },
};

module.exports = ActivityService;