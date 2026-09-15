const ActivityDTO = require("./dto/ActivityDTO");

class ActivityAssembler {

    static toDTO(activity) {

        if (!activity) {
            return null;
        }

        return new ActivityDTO({
            id:
                activity._id?.toString() ??
                activity.id,

            name:
                activity.name,

            location:
                activity.location ??
                activity.addresse ??
                activity.address ??
                null,

            rating:
                activity.rating ?? null,

            reviews:
                activity.reviews ??
                activity.numberofreviews ??
                0,

            imageurl:
                activity.imageurl ??
                activity.image ??
                null,

            type:
                activity.type ??
                activity.activitytype ??
                null,
        });
    }

    static toDTOList(activities) {

        if (!activities) {
            return [];
        }

        return activities.map(
            activity => this.toDTO(activity)
        );
    }
}

module.exports = ActivityAssembler;