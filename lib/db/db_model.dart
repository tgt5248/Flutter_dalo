class Data {
  final String date;
  final String time;
  final String loc;

  Data({
    required this.date,
    required this.time,
    required this.loc,
  });
  // required : 값 필수

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'time': time,
      'loc': loc,
    };
  }
}
