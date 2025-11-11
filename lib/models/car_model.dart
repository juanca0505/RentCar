class CarModel {
  final String id;
  final String ownerId;
  final String brand;
  final String model;
  final int year;
  final double pricePerDay;
  final bool available;
  final String? imageUrl;
  final String? category; // ✅ Campo nuevo para filtros
  final String? description; // opcional (para detalle)

  CarModel({
    required this.id,
    required this.ownerId,
    required this.brand,
    required this.model,
    required this.year,
    required this.pricePerDay,
    required this.available,
    this.imageUrl,
    this.category,
    this.description,
  });

  // ✅ Convertir CarModel a mapa (para Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'brand': brand,
      'model': model,
      'year': year,
      'pricePerDay': pricePerDay,
      'available': available,
      'imageUrl': imageUrl,
      'category': category,
      'description': description,
    };
  }

  // ✅ Crear CarModel desde documento Firestore
  factory CarModel.fromMap(Map<String, dynamic> map) {
    return CarModel(
      id: map['id'] ?? '',
      ownerId: map['ownerId'] ?? '',
      brand: map['brand'] ?? '',
      model: map['model'] ?? '',
      year: (map['year'] ?? 0).toInt(),
      pricePerDay: (map['pricePerDay'] ?? 0).toDouble(),
      available: map['available'] ?? true,
      imageUrl: map['imageUrl'],
      category: map['category'], // ✅ Agregado
      description: map['description'],
    );
  }
}
