const restaurantDAO = require('../../dao/restaurantDAO');

const Restaurant = require('../../domain/restaurants/BasicRestaurant');

const PriceLevelEnum = require('../../domain/restaurants/enums/PriceLevelEnum');

const RestaurantMapper = require('./RestaurantMapper');

const RestaurantAssembler = require('./RestaurantAssembler');


const RestaurantService = {

    async createRestaurant(data) {

        const doc = await restaurantDAO.create(data);

        if (!doc) {
            return null;
        }

        const restaurant = RestaurantMapper.fromPersistence(doc);

        return RestaurantAssembler.toDTO(restaurant);
    },

    async getRestaurantById(id) {

        const doc = await restaurantDAO.getById(id);

        if (!doc) {
            return null;
        }

        const restaurant = RestaurantMapper.fromPersistence(doc);

        return RestaurantAssembler.toDTO(restaurant);
    },

    async updateRestaurant(id, updates) {

        const doc = await restaurantDAO.update(id, updates);

        if (!doc) {
            return null;
        }

        const restaurant = RestaurantMapper.fromPersistence(doc);

        return RestaurantAssembler.toDTO(restaurant);
    },

    async deleteRestaurant(id) {
        return await restaurantDAO.delete(id);
    },

    async getAllRestaurants(filter = {}) {

        const docs = await restaurantDAO.getAll(filter);

        const restaurants = docs.map(doc => RestaurantMapper.fromPersistence(doc));

        return RestaurantAssembler.toDTOList(restaurants);
    },

    async getRestaurantsForPlanning(filters = {}) {
        const docs = await restaurantDAO.getAll(filters);

        return docs.map(doc => RestaurantMapper.fromPersistence(doc)).filter(Boolean);
    },

    async search(filters = {}) {

        const normalizedFilters = this.normalizeSearchFilters(filters);

        const docs = await restaurantDAO.search(normalizedFilters);

        const restaurants =docs.map(doc => RestaurantMapper.fromPersistence(doc));

        return RestaurantAssembler.toDTOList(restaurants);
    },

    normalizeSearchFilters(filters = {}) {

        const result = {...filters,};


        if (result.minPrice !== undefined && result.maxPrice !== undefined) {

            result.priceLevel = PriceLevelEnum.fromRange(result.minPrice, result.maxPrice);

            delete result.minPrice;
            delete result.maxPrice;
        }


        if (result.cuisines) {

            result.cuisines = Restaurant.cleanCuisineTypes(result.cuisines);
        }

        return result;
    },

    cleanCuisineTypes(cuisines) {
        return Restaurant.cleanCuisineTypes(cuisines);
    },

    convertPriceLevel(priceLevel) {
        return PriceLevelEnum.toNumeric(priceLevel);
    },
};


module.exports = RestaurantService;