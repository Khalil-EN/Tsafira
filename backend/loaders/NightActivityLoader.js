const fs = require("fs/promises");
const path = require("path");

const NIGHT_ACTIVITIES_FILE = path.join(
    __dirname,
    "../data/nightActivities.json"
);

const NightActivityLoader = {
    async load() {
        const content = await fs.readFile(
            NIGHT_ACTIVITIES_FILE,
            "utf-8"
        );

        return JSON.parse(content);
    },
};

module.exports = NightActivityLoader;