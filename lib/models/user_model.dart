class UserModel {
  String userId;
  String name;
  String email;
  String profileImageUrl;

  UserModel(
    this.userId,
    this.name,
    this.email, {
    this.profileImageUrl = "",
  });

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "name": name,
      "email": email,
      "profileImageUrl": profileImageUrl,
    };
  }
}
