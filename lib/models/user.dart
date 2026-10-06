class AppUser {
  final String id;
  final String name;

  AppUser({required this.id, required this.name});

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'],
      name: map['name'],
    );
  }
}
