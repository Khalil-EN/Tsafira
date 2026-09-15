class ResidenceDTO {

    constructor({
        id,
        name,
        description,
        location,
        price,
        rating,
        reviews,
        imageurl,
        detailimages = [],
        amenities = [],
    }) {

        this.id = id;
        this.name = name;
        this.description = description;
        this.location = location;
        this.price = price;
        this.rating = rating;
        this.reviews = reviews;
        this.imageurl = imageurl;
        this.detailimages = detailimages;
        this.amenities = amenities;

        Object.freeze(this);
    }

}

module.exports = ResidenceDTO;