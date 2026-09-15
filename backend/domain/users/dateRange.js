/**
 * DateRange — value object representing a half-open time interval [start, end).
 *
 * Lives in the user domain because its only consumer is FreemiumUser,
 * which uses it to reason about daily suggestion quotas.
 */
class DateRange {
  constructor(start, end) {
    this.start = start;
    this.end   = end;
  }

  contains(date) {
    return date >= this.start && date < this.end;
  }

  /** Returns a DateRange spanning today: [00:00:00, 00:00:00 tomorrow) */
  static today() {
    const start = new Date();
    start.setHours(0, 0, 0, 0);
    const end = new Date(start);
    end.setDate(end.getDate() + 1);
    return new DateRange(start, end);
  }
}

module.exports = DateRange;