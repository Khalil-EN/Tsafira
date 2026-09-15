const Restaurant =
  require('../../domain/restaurants/BasicRestaurant');

class RestaurantMapper {
  static fromPersistence(doc) {
    if (!doc) {
      return null;
    }

    return new Restaurant({
      id:
        doc._id?.toString() ??
        doc.id ??
        null,

      name:
        doc.name ?? '',

      address:
        doc.address ?? null,

      priceLevel:
        doc.pricelevel ??
        doc.priceLevel ??
        null,

      rating:
        Number(doc.rating) || 0,

      numberOfReviews:
        Number(
          doc.numberofreviews ??
          doc.numberOfReviews
        ) || 0,

      openingHours:
        doc.openinghours ??
        doc.openingHours ??
        null,

      image:
        doc.image ??
        doc.imageurl ??
        null,

      images:
        doc.images ??
        doc.secondary_images ??
        [],

      longitude:
        Number.isFinite(
          Number(doc.longitude)
        )
          ? Number(doc.longitude)
          : null,

      latitude:
        Number.isFinite(
          Number(doc.latitude)
        )
          ? Number(doc.latitude)
          : null,

      contactInfo:
        doc.contact_info ??
        doc.contactInfo ??
        null,

      description:
        doc.description ?? '',

      facilities:
        doc.facilities ?? [],

      meals:
        doc.meals ?? [],

      tags:
        doc.tags ?? [],

      cuisines:
        doc.cuisines ?? [],
    });
  }

  static fromPersistenceList(docs) {
    if (!Array.isArray(docs)) {
      return [];
    }

    return docs
      .map(doc =>
        RestaurantMapper.fromPersistence(
          doc
        )
      )
      .filter(Boolean);
  }
}

module.exports =
  RestaurantMapper;