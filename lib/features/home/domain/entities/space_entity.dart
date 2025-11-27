class SpaceEntity {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String? address;
  final double? rating;

  const SpaceEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.address,
    this.rating,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpaceEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
