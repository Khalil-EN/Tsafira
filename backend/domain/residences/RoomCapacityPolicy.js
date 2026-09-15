class RoomCapacityPolicy {

    static getCapacity() {
        // Business assumption:
        // one residence room can accommodate two people.
        return 2;
    }

    static getRequiredRooms(numberOfPeople) {
        const people =
            Number(numberOfPeople) || 0;

        if (people <= 0) {
            return 0;
        }

        return Math.ceil(
            people / this.getCapacity()
        );
    }
}

module.exports = RoomCapacityPolicy;