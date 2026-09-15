class TripDay {
  final int day;
  final DateTime date;
  final List<String> attractions;
  final List<String> transports;

  TripDay({
    required this.day,
    required this.date,
    List<String>? attractions,
    List<String>? transports,
  })  : attractions = attractions ?? [],
        transports = transports ?? [];

  String get formattedDate => '${date.day}/${date.month}/${date.year}';
}