import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/car_model.dart';

class CarService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔹 Crear o actualizar carro
  Future<void> saveCar(CarModel car, {File? imageFile}) async {
    String? imageUrl = car.imageUrl;

    // 🖼️ Subir imagen nueva si se seleccionó
    if (imageFile != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('cars')
          .child('${car.id}.jpg');
      await ref.putFile(imageFile);
      imageUrl = await ref.getDownloadURL();
    }

    // 📦 Datos a guardar o actualizar
    final carData = {
      ...car.toMap(),
      'imageUrl': imageUrl,
      'fechaCreacion': FieldValue.serverTimestamp(),
      // 🔧 Aseguramos que existan todos los nuevos campos
      'available': car.available,
      'category': car.category ?? 'Sin categoría',
      'description': car.description ?? '',
      'rentedBy': car.available ? null : car.ownerId,
      'rentStatus': car.available ? 'disponible' : 'rentado',
    };

    // 🧩 Guardar (merge mantiene datos previos)
    await _db
        .collection('cars')
        .doc(car.id)
        .set(carData, SetOptions(merge: true));
  }

  // 🔹 Obtener los carros del usuario actual
  Stream<List<CarModel>> getCarsByUser(String uid) {
    return _db
        .collection('cars')
        .where('ownerId', isEqualTo: uid)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => CarModel.fromMap(d.data())).toList());
  }

  // 🔹 Obtener todos los carros (para la vista general)
  Stream<List<CarModel>> getAllCars() {
    return _db.collection('cars').snapshots().map(
        (snap) => snap.docs.map((d) => CarModel.fromMap(d.data())).toList());
  }

  // 🔹 Eliminar carro y su imagen asociada
  Future<void> deleteCar(String carId) async {
    await _db.collection('cars').doc(carId).delete();

    final ref = FirebaseStorage.instance.ref('cars/$carId.jpg');
    try {
      await ref.delete();
    } catch (_) {
      // Si no existe la imagen, ignoramos el error
    }
  }

  // 🔹 Marcar carro como rentado
  Future<void> markAsRented(String carId, String rentedBy) async {
    await _db.collection('cars').doc(carId).update({
      'available': false,
      'rentedBy': rentedBy,
      'rentStatus': 'rentado',
    });
  }

  // 🔹 Marcar carro como disponible (cuando finaliza la renta)
  Future<void> markAsAvailable(String carId) async {
    await _db.collection('cars').doc(carId).update({
      'available': true,
      'rentedBy': null,
      'rentStatus': 'disponible',
    });
  }
}
