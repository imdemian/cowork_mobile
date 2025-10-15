// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: (json['id'] as num).toInt(),
  email: json['email'] as String,
<<<<<<< Updated upstream
  first_name: json['first_name'] as String?,
  last_name: json['last_name'] as String?,
=======
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
>>>>>>> Stashed changes
  token: json['token'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
<<<<<<< Updated upstream
  'first_name': instance.first_name,
  'last_name': instance.last_name,
=======
  'firstName': instance.firstName,
  'lastName': instance.lastName,
>>>>>>> Stashed changes
  'token': instance.token,
};
