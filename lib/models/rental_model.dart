import 'package:cloud_firestore/cloud_firestore.dart';

class RentalModel {
  final String id;
  final String userId; // Cliente que renta
  final String ownerId; // Dueño del carro
  final String carId;
  final String carBrand;
  final String carModel;
  final String carImage;
  final double pricePerDay;
  final DateTime rentDate;
  final bool active;

  // 👇 NUEVOS CAMPOS
  final String renterName;
  final String renterEmail;

  RentalModel({
    required this.id,
    required this.userId,
    required this.ownerId,
    required this.carId,
    required this.carBrand,
    required this.carModel,
    required this.carImage,
    required this.pricePerDay,
    required this.rentDate,
    required this.renterName,
    required this.renterEmail,
    this.active = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'ownerId': ownerId,
      'carId': carId,
      'carBrand': carBrand,
      'carModel': carModel,
      'carImage': carImage,
      'pricePerDay': pricePerDay,
      'rentDate': rentDate,
      'active': active,
      'renterName': renterName,
      'renterEmail': renterEmail,
    };
  }

  factory RentalModel.fromMap(Map<String, dynamic> map) {
    return RentalModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      ownerId: map['ownerId'] ?? '',
      carId: map['carId'] ?? '',
      carBrand: map['carBrand'] ?? '',
      carModel: map['carModel'] ?? '',
      carImage: map['carImage'] ?? '',
      pricePerDay: (map['pricePerDay'] ?? 0).toDouble(),
      rentDate: (map['rentDate'] is Timestamp)
          ? (map['rentDate'] as Timestamp).toDate()
          : DateTime.tryParse(map['rentDate'] ?? '') ?? DateTime.now(),
      active: map['active'] ?? true,
      renterName: map['renterName'] ?? '',
      renterEmail: map['renterEmail'] ?? '',
    );
  }
}
