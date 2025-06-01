class UserProfile {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String profileImage;
  final String password;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.profileImage,
    required this.password,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'] ?? '',
    address: json['address'] ?? '',
    profileImage: json['profileImage'] ?? '',
    password: json['password'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'address': address,
    'profileImage': profileImage,
    'password': password,
  };

  UserProfile copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? profileImage,
    String? password,
  }) => UserProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    address: address ?? this.address,
    profileImage: profileImage ?? this.profileImage,
    password: password ?? this.password,
  );
}
