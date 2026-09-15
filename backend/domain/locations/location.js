class Location {
  constructor({ id, name, description, address, city, region,
                postalCode, country, latitude, longitude, timeZone, createdAt }) {
    this.id         = id;
    this.name       = name;
    this.description = description;
    this.address    = address;
    this.city       = city;
    this.region     = region;
    this.postalCode = postalCode;
    this.country    = country;
    this.latitude   = latitude;
    this.longitude  = longitude;
    this.timeZone   = timeZone;
    this.createdAt  = createdAt || new Date();
  }

  getFullAddress()       { return `${this.address}, ${this.city}, ${this.country}`; }
  getCoordinates()       { return { lat: this.latitude, lng: this.longitude }; }
  getCoordinatesString() { return `${this.latitude},${this.longitude}`; }

  /** Great-circle distance in km to another Location instance. */
  calculateDistance(other) {
    return Location.distanceBetween(this, other);
  }

  isNearby(other, maxKm = 10) {
    return this.calculateDistance(other) <= maxKm;
  }

  /**
   * Static convenience — accepts any object with latitude/longitude.
   * Used by strategies so they don't need to construct Location instances.
   */
  static distanceBetween(a, b) {
    const toRad = v => (v * Math.PI) / 180;
    const R     = 6371;
    const dLat  = toRad(b.latitude  - a.latitude);
    const dLon  = toRad(b.longitude - a.longitude);
    const sin2  =
      Math.sin(dLat / 2) ** 2 +
      Math.cos(toRad(a.latitude)) * Math.cos(toRad(b.latitude)) * Math.sin(dLon / 2) ** 2;
    return R * 2 * Math.atan2(Math.sqrt(sin2), Math.sqrt(1 - sin2));
  }

  toJSON() { return { ...this }; }
}

module.exports = Location;