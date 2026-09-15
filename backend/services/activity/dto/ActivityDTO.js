class ActivityDTO {
    constructor({
        id,
        name,
        address,
        rating,
        reviews,
        imageurl,
        type,
    }) {
        this.id = id;
        this.name = name;
        this.address = address;
        this.rating = rating;
        this.reviews = reviews;
        this.imageurl = imageurl;
        this.type = type;

        Object.freeze(this);
    }
}

module.exports = ActivityDTO;