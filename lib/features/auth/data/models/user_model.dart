import 'package:json_annotation/json_annotation.dart';
import 'package:cowork_frontend/features/auth/domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int id;
  final String email;
  final String? first_name;
  final String? last_name;
  final String? token;

  UserModel({
    required this.id,
    required this.email,
    this.first_name,
    this.last_name,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserEntity toEntity() => UserEntity(
    id: id,
    email: email,
    firstName: first_name,
    lastName: last_name,
    token: token,
  );

  factory UserModel.fromEntity(UserEntity entity) => UserModel(
    id: entity.id,
    email: entity.email,
    first_name: entity.firstName,
    last_name: entity.lastName,
    token: entity.token,
  );
}
