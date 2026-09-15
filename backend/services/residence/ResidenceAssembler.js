const ResidenceDTO = require("./dto/ResidenceDTO");

class ResidenceAssembler {

    static toDTO(residence) {

        if (!residence) {
            return null;
        }

        return new ResidenceDTO({

            id:
                residence.id,

            name:
                residence.name,

            description:
                residence.description,

            location:
                residence.address,

            price:
                residence.pricerange,

            rating:
                residence.rating,

            reviews:
                residence.numberofreviews,

            imageurl:
                residence.image,

            detailimages:
                ResidenceAssembler.toArray(
                    residence.secondary_images
                ),

            amenities:
                ResidenceAssembler.toArray(
                    residence.amenities
                ),

        });
    }


    static toArray(value) {

        if (Array.isArray(value)) {
            return value;
        }

        if (typeof value === "string") {

            try {
                return JSON.parse(value);
            } catch {

                try {
                    return JSON.parse(
                        value.replace(/'/g, '"')
                    );
                } catch {
                    return [];
                }

            }
        }

        return [];
    }

}

module.exports = ResidenceAssembler;