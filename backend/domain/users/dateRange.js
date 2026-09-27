
class DateRange {
  constructor(start, end) {
    this.start = start;
    this.end   = end;
  }

  contains(date) {
    return date >= this.start && date < this.end;
  }

  static today() {
    const start = new Date();
    start.setHours(0, 0, 0, 0);
    const end = new Date(start);
    end.setDate(end.getDate() + 1);
    return new DateRange(start, end);
  }
}

module.exports = DateRange;