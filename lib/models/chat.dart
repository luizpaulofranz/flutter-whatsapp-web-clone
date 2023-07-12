class Chat {
  String fromUserId;
  String toUserId;
  String lastMessage;
  String toUserName;
  String toUserEmail;
  String toUserProfilePicture;

  Chat(
    this.fromUserId,
    this.toUserId,
    this.lastMessage,
    this.toUserName,
    this.toUserEmail,
    this.toUserProfilePicture,
  );

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "fromUserId": fromUserId,
      "toUserId": toUserId,
      "lastMessage": lastMessage,
      "toUserName": toUserName,
      "toUserEmail": toUserEmail,
      "toUserProfilePicture": toUserProfilePicture,
    };

    return map;
  }
}
