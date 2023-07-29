class Message {
  Message({
    required this.msg,
    required this.otId,
    required this.read,
    required this.type,
    required this.fromId,
    required this.sent,
  });
  late final String msg;
  late final String otId;
  late final String read;
  late final Type type;
  late final String fromId;
  late final String sent;

  Message.fromJson(Map<String, dynamic> json) {
    msg = json['msg'].toString();
    otId = json['otId'].toString();
    read = json['read'].toString();
    type = json['type'].toString() == Type.text.name ? Type.text : Type.image;
    fromId = json['fromId'].toString();
    sent = json['sent'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['msg'] = msg;
    data['otId'] = otId;
    data['read'] = read;
    data['type'] = type.name;
    data['fromId'] = fromId;
    data['sent'] = sent;
    return data;
  }
}

enum Type { text, image }
