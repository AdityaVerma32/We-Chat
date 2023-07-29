class ChatUser {
  late String image;
  late String about;
  late String name;
  late String createdAt;
  late String id;
  late String email;
  late String pushToken;
  late bool isOnline;
  late String lastActive;

  ChatUser(
      {required this.image,
      required this.about,
      required this.name,
      required this.createdAt,
      required this.id,
      required this.email,
      required this.pushToken,
      required this.isOnline,
      required this.lastActive});

  // used whil getting data from the Backend
  ChatUser.fromJson(Map<String, dynamic> json) {
    image = json['image'] ?? '';
    about = json['about'] ?? '';
    name = json['name'] ?? '';
    createdAt = json['created_at'] ?? '';
    id = json['id'] ?? '';
    email = json['email'] ?? '';
    pushToken = json['push_token'] ?? '';
    isOnline = json['is_online'] ?? '';
    lastActive = json['last_active'];
  }

  // used while transferring data to backend
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['image'] = this.image;
    data['about'] = this.about;
    data['name'] = this.name;
    data['created_at'] = this.createdAt;
    data['id'] = this.id;
    data['email'] = this.email;
    data['push_token'] = this.pushToken;
    data['is_online'] = this.isOnline;
    data['last_active'] = this.lastActive;
    return data;
  }
}
