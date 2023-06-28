class Message {
  String userId;
  String text;
  String date;

  Message(
    this.userId,
    this.text,
    this.date,
  );

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "userId": userId,
      "text": text,
      "date": date,
    };

    return map;
  }
}
