class PetModel {
  final int id;
  final String name;
  final String species;
  final String? breed;
  final String? color;
  final DateTime? birthDate;

  PetModel({
    required this.id,
    required this.name,
    required this.species,
    this.breed,
    this.color,
    this.birthDate,
  });

  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      id: json['id'] as int,
      name: json['name'] as String,
      species: json['species'] as String,
      breed: json['breed'] as String?,
      color: json['color'] as String?,
      birthDate:
          json['birth_date'] != null
              ? DateTime.parse(json['birth_date'] as String)
              : null,
    );
  }
}
