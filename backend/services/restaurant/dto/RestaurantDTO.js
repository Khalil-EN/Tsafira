class RestaurantDTO {
    constructor({
        id,
        name,
        description,
        location,
        price,
        priceLevel,
        rating,
        reviews,
        image,
        detailimages,
        openingHours,
        cuisines,
        tags,
        facilities,
        meals,
    }) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.location = location;
        this.price = price;
        this.priceLevel = priceLevel;
        this.rating = rating;
        this.reviews = reviews;
        this.image = image;
        this.detailimages = Array.isArray(detailimages)
            ? detailimages
            : [];
        this.openingHours = openingHours;
        this.cuisines = Array.isArray(cuisines) ? cuisines : [];
        this.tags = Array.isArray(tags) ? tags : [];
        this.facilities = Array.isArray(facilities) ? facilities : [];
        this.meals = Array.isArray(meals) ? meals : [];
    }
}

module.exports = RestaurantDTO;