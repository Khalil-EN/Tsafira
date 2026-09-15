const Activity = require('../../domain/activities/BasicActivity');

class ActivityMapper {
    static fromPersistence(doc) {
        if (!doc) {
            return null;
        }

        return new Activity({
            id: doc._id?.toString() ?? doc.id ?? null,

            name: doc.name,

            description: doc.description,

            activityType:
                doc.activitytype ??
                doc.activityType ??
                null,

            numberOfReviews:
                doc.numberofreviews ??
                doc.numberOfReviews ??
                0,

            rating: doc.rating,

            image:
                doc.image ??
                doc.imageurl ??
                null,

            address:
                doc.addresse ??
                doc.address ??
                null,

            longitude: doc.longitude,
            latitude: doc.latitude,

            price:
                doc.price ??
                doc.priceperperson ??
                doc.pricePerPerson ??
                null,
        });
    }

    static toPersistence(activity) {
        if (!activity) {
            return null;
        }

        return {
            name: activity.name,
            description: activity.description,

            activitytype: activity.activityType,

            numberofreviews:
                activity.numberOfReviews,

            rating: activity.rating,

            image: activity.image,

            addresse: activity.address,

            longitude: activity.longitude,
            latitude: activity.latitude,

            price: activity.price,
        };
    }
}

module.exports = ActivityMapper;