const RestaurantDTO =
    require('./dto/RestaurantDTO');

class RestaurantAssembler {

    // ============================================================
    // DOMAIN → DTO
    // ============================================================

    static toDTO(restaurant) {
        
    if (!restaurant) return null;

    const dto = new RestaurantDTO({
        id: restaurant.id,
        name: restaurant.name,
        description: restaurant.description,
        location: restaurant.address,
        price: restaurant.priceLevel,
        priceLevel: restaurant.priceLevel,
        rating: restaurant.rating,
        reviews: restaurant.numberOfReviews,
        image: restaurant.image,
        detailimages: restaurant.images,
        openingHours: restaurant.openingHours,
        cuisines: restaurant.cuisines,
        tags: restaurant.tags,
        facilities: restaurant.facilities,
        meals: restaurant.meals,
    });

    return dto;
}


    // ============================================================
    // DOMAIN LIST → DTO LIST
    // ============================================================

    static toDTOList(restaurants) {

        if (!Array.isArray(restaurants)) {
            return [];
        }

        return restaurants.map(
            restaurant =>
                RestaurantAssembler.toDTO(
                    restaurant
                )
        );
    }
}


module.exports = RestaurantAssembler;