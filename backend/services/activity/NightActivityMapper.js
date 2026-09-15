const Activity = require("../../domain/activities/BasicActivity");

class NightActivityMapper {

    static fromExternal(data) {
        if (!data) {
            return null;
        }

        return new Activity({
            id: data.id ?? null,
            name: data.name,
            description: data.description,
            activityType: data.activityType ?? data.type ?? null,
            numberOfReviews: data.numberOfReviews ?? data.reviews ?? 0,
            rating: data.rating ?? 0,
            image: data.image ?? data.imageUrl ?? null,
            address: data.address ?? data.location ?? null,
            longitude: data.longitude ?? null,
            latitude: data.latitude ?? null,
            price: data.price ?? null,
        });
    }
}

module.exports = NightActivityMapper;