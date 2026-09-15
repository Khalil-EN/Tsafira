class CommunitySummaryDTO {
    constructor({
        id,
        name,
        coverImage = null,
        privacy = null,
    }) {
        this.id = id;
        this.name = name;
        this.coverImage = coverImage;
        this.privacy = privacy;

        Object.freeze(this);
    }
}

module.exports = CommunitySummaryDTO;