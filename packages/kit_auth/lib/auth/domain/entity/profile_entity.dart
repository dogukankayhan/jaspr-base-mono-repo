class Profile {
  final String id;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;
  final int coinCount;
  final String? about;

  const Profile({
    required this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    this.coinCount = 0,
    this.about,
  });

  String get fullName {
    final f = firstName ?? "";
    final l = lastName ?? "";
    final s = ("$f $l").trim();
    return s.isEmpty ? (email ?? id) : s;
  }
}
