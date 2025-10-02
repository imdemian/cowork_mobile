import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/space_entity.dart';

part 'space_model.g.dart';

@JsonSerializable()
class SpaceModel {
  final int id;
  final String name;
  final String description;
  final double price;
  @JsonKey(name: 'image_url')
  final String imageUrl;
  final String? address;
  final double? rating;

  SpaceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.address,
    this.rating,
  });

  factory SpaceModel.fromJson(Map<String, dynamic> json) =>
      _$SpaceModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$SpaceModelToJson(this);

  SpaceEntity toEntity() => SpaceEntity(
        id: id,
        name: name,
        description: description,
        price: price,
        imageUrl: imageUrl,
        address: address,
        rating: rating,
      );

  factory SpaceModel.fromEntity(SpaceEntity entity) => SpaceModel(
        id: entity.id,
        name: entity.name,
        description: entity.description,
        price: entity.price,
        imageUrl: entity.imageUrl,
        address: entity.address,
        rating: entity.rating,
      );
}