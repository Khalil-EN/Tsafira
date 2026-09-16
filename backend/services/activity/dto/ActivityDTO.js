class ActivityDTO {
    constructor({
        id,
        name,
        location,
        rating,
        reviews,
        imageurl,
        type,
    }) {
        this.id = id;
        this.name = name;
        this.location = location;
        this.rating = rating;
        this.reviews = reviews;
        this.imageurl = imageurl;
        this.type = type;

        Object.freeze(this);
    }
}

module.exports = ActivityDTO;