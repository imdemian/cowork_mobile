class UserEntity {
  final int id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? token;

  const UserEntity({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.token,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UserEntity && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
