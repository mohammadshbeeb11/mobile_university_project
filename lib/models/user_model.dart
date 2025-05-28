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

  // Factory constructor for creating from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      profileImage: json['profileImage'] ?? '',
      password: json['password'] ?? '',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'profileImage': profileImage,
      'password': password,
    };
  }

  // Create a copy with updated values
  UserProfile copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? profileImage,
    String? password,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profileImage: profileImage ?? this.profileImage,
      password: password ?? this.password,
    );
  }
}
