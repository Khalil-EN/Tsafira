const TIERS = [
    { label: '$', value: 15 },
    { label: '$$', value: 30 },
    { label: '$$$', value: 60 },
    { label: '$$$$', value: 120 },
];

const PriceLevelEnum = Object.freeze({
    BUDGET: '$',
    MODERATE: '$$',
    EXPENSIVE: '$$$',
    LUXURY: '$$$$',

    toNumeric(priceLevel) {
        if (
            !priceLevel ||
            typeof priceLevel !== 'string'
        ) {
            return null;
        }

        const parts = priceLevel
            .replace(/\s+/g, '')
            .split('-');

        const values = parts.map(part => {
            const tier = TIERS.find(
                item => item.label === part
            );

            return tier ? tier.value : null;
        });

        if (values.some(value => value === null)) {
            return null;
        }

        if (values.length === 2) {
            return (values[0] + values[1]) / 2;
        }

        return values[0] ?? null;
    },

    fromRange(minPrice, maxPrice) {
        function closest(price) {
            if (!Number.isFinite(Number(price))) {
                return null;
            }

            const numericPrice = Number(price);

            if (numericPrice <= TIERS[0].value) {
                return TIERS[0].label;
            }

            if (
                numericPrice >=
                TIERS[TIERS.length - 1].value
            ) {
                return TIERS[TIERS.length - 1].label;
            }

            for (let i = 0; i < TIERS.length - 1; i++) {
                if (
                    numericPrice >= TIERS[i].value &&
                    numericPrice < TIERS[i + 1].value
                ) {
                    return TIERS[i].label;
                }
            }

            return null;
        }

        const lo = closest(minPrice);
        const hi = closest(maxPrice);

        if (!lo && !hi) {
            return null;
        }

        if (!lo) {
            return hi;
        }

        if (!hi) {
            return lo;
        }

        return lo === hi
            ? lo
            : `${lo}-${hi}`;
    },
});

module.exports = PriceLevelEnum;