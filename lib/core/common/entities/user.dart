class User {
  final String id;
  final String email;
  final String name;
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final String? country;
  final String? gender;
  final double? height;
  final double? weight;
  final String? goal;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.country,
    this.gender,
    this.height,
    this.weight,
    this.goal,
    this.createdAt,
    this.updatedAt,
  });
}
