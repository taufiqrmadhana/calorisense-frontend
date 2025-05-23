// features/auth/data/models/user_model.dart
import 'package:calorisense/core/common/entities/user.dart';
import 'package:flutter/foundation.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.firstName,
    super.lastName,
    super.dateOfBirth,
    super.country,
    super.gender,
    super.height,
    super.weight,
    super.goal,
    super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '', // Email dari tabel users/auth
      name:
          map['name'] ??
          (map['user_metadata']?['name'] ??
              ''), // Ambil 'name' dari kolom 'name' atau metadata
      firstName: map['first_name'],
      lastName: map['last_name'],
      dateOfBirth:
          map['date_of_birth'] != null
              ? DateTime.tryParse(map['date_of_birth'])
              : null,
      country: map['country'],
      gender: map['gender'],
      height: (map['height'] as num?)?.toDouble(),
      weight: (map['weight'] as num?)?.toDouble(),
      goal: map['goal'],
      createdAt:
          map['created_at'] != null
              ? DateTime.tryParse(map['created_at'])
              : null,
      updatedAt:
          map['updated_at'] != null
              ? DateTime.tryParse(map['updated_at'])
              : null,
    );
  }

  // Method untuk membuat map yang akan diinsert ke tabel users
  // Hanya berisi data yang relevan saat signup awal
  Map<String, dynamic> toJsonForUsersTableInsert() {
    return {
      'id': id,
      'email': email,
      'name': name, // username
      'first_name': firstName, // akan null saat signup
      'last_name': lastName, // akan null saat signup
      'date_of_birth': dateOfBirth?.toIso8601String(), // akan null saat signup
      'country': country, // akan null saat signup
      'gender': gender, // akan null saat signup
      'height': height, // akan null saat signup
      'weight': weight, // akan null saat signup
      'goal': goal, // akan null saat signup
      // created_at dan updated_at biasanya dihandle Supabase
    };
  }

  // Method baru untuk update data ke tabel 'users'
  Map<String, dynamic> toJsonForUsersTableUpdate() {
    return {
      // id tidak perlu diupdate
      // email tidak perlu diupdate
      // name tidak perlu diupdate
      'first_name': firstName,
      'last_name': lastName,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'country': country,
      'gender': gender,
      'height': height,
      'weight': weight,
      'goal': goal,
      'updated_at':
          DateTime.now().toIso8601String(), // Pastikan updated_at diupdate
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    ValueGetter<String?>? firstName,
    ValueGetter<String?>? lastName,
    ValueGetter<DateTime?>? dateOfBirth,
    ValueGetter<String?>? country,
    ValueGetter<String?>? gender,
    ValueGetter<double?>? height,
    ValueGetter<double?>? weight,
    ValueGetter<String?>? goal,
    ValueGetter<DateTime?>? createdAt,
    ValueGetter<DateTime?>? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      firstName: firstName != null ? firstName() : this.firstName,
      lastName: lastName != null ? lastName() : this.lastName,
      dateOfBirth: dateOfBirth != null ? dateOfBirth() : this.dateOfBirth,
      country: country != null ? country() : this.country,
      gender: gender != null ? gender() : this.gender,
      height: height != null ? height() : this.height,
      weight: weight != null ? weight() : this.weight,
      goal: goal != null ? goal() : this.goal,
      createdAt: createdAt != null ? createdAt() : this.createdAt,
      updatedAt: updatedAt != null ? updatedAt() : this.updatedAt,
    );
  }
}
