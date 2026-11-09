class UserDTO {
  final String id;
  final String name;
  final String email;

  UserDTO({required this.id, required this.name, required this.email});

  factory UserDTO.fromJson(Map<String, dynamic> json) => UserDTO(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email};
}
