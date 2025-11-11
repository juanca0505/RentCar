class UserModel {
  String uid;
  String name;
  String email;
  String? photoUrl;
  String? cedula;
  String? direccion;
  String? celular;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.cedula,
    this.direccion,
    this.celular,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'cedula': cedula,
      'direccion': direccion,
      'celular': celular,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      cedula: map['cedula'],
      direccion: map['direccion'],
      celular: map['celular'],
    );
  }
}
