import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rental_model.dart';

class RentalService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Crear nueva renta
  Future<void> rentCar(RentalModel rental) async {
    await _db.collection('rentals').doc(rental.id).set(rental.toMap());
  }

  // Obtener rentas por usuario (cliente)
  Stream<List<RentalModel>> getRentalsByUser(String userId) {
    return _db
        .collection('rentals')
        .where('userId', isEqualTo: userId)
        .orderBy('rentDate', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => RentalModel.fromMap(doc.data())).toList());
  }

  // 🔥 Obtener rentas por propietario (dueño del carro)
  Stream<List<RentalModel>> getRentalsByOwner(String ownerId) {
    return _db
        .collection('rentals')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('rentDate', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => RentalModel.fromMap(doc.data())).toList());
  }

  // Finalizar renta
  Future<void> finishRental(String rentalId) async {
    await _db.collection('rentals').doc(rentalId).update({'active': false});
  }

  // Eliminar renta
  Future<void> deleteRental(String rentalId) async {
    await _db.collection('rentals').doc(rentalId).delete();
  }
}
