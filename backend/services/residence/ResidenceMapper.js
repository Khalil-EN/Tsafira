const Residence = require('../../domain/residences/basicResidence');

class ResidenceMapper {
    static fromPersistence(doc) {
        if (!doc) {
            return null;
        }

        return new Residence({
            id: doc._id?.toString() ?? doc.id ?? null,

            name: doc.name,

            description: doc.description,

            address: doc.address,

            // One room / one night
            priceRange:
                doc.pricerange ??
                doc.priceRange ??
                null,

            rating: doc.rating,

            numberOfReviews:
                doc.numberofreviews ??
                doc.numberOfReviews ??
                0,

            checkInDate:
                doc.checkindate ??
                doc.checkInDate ??
                null,

            checkOutDate:
                doc.checkoutdate ??
                doc.checkOutDate ??
                null,

            image:
                doc.image ??
                doc.imageurl ??
                null,

            secondaryImages:
                doc.secondary_images ??
                doc.secondaryImages ??
                [],

            longitude: doc.longitude,
            latitude: doc.latitude,

            contactInfo:
                doc.contact_info ??
                doc.contactInfo ??
                null,

            amenities:
                doc.amenities ?? [],
        });
    }

    static fromPersistenceList(docs) {
        if (!Array.isArray(docs)) {
            return [];
        }

        return docs
        .map(doc =>
            ResidenceMapper.fromPersistence(
            doc
            )
        )
        .filter(Boolean);
    }

    static toPersistence(residence) {
        if (!residence) {
            return null;
        }

        return {
            name: residence.name,
            description: residence.description,
            address: residence.address,

            pricerange: residence.priceRange,

            rating: residence.rating,

            numberofreviews:
                residence.numberOfReviews,

            checkindate:
                residence.checkInDate,

            checkoutdate:
                residence.checkOutDate,

            image: residence.image,

            secondary_images:
                residence.secondaryImages,

            longitude: residence.longitude,
            latitude: residence.latitude,

            contact_info:
                residence.contactInfo,

            amenities:
                residence.amenities,
        };
    }
}

module.exports = ResidenceMapper;