import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/rental_model.dart';
import '../services/rental_service.dart';

class MyCarRentalsScreen extends StatelessWidget {
  const MyCarRentalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user!;
    final rentalService = RentalService();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Rentas de mis vehículos 🚗"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<RentalModel>>(
        stream: rentalService.getRentalsByOwner(user.uid),
        builder: (context, snapshot) {
          // ⏳ Estado de carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            );
          }

          // Error
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Error al cargar las rentas.",
                style: TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
            );
          }

          // Lista vacía
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Ninguno de tus carros ha sido rentado aún 😕",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          final rentals = snapshot.data!;

          return ListView.builder(
            itemCount: rentals.length,
            itemBuilder: (context, i) {
              final rent = rentals[i];
              final fecha = rent.rentDate;
              final fechaStr =
                  "${fecha.day}/${fecha.month}/${fecha.year} "
                  "${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}";

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: Row(
                    children: [
                      // Imagen del carro
                      rent.carImage.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                rent.carImage,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image_not_supported,
                                        color: Colors.grey, size: 50),
                              ),
                            )
                          : const Icon(Icons.directions_car,
                              size: 60, color: Colors.grey),

                      const SizedBox(width: 10),

                      // Detalle textual
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${rent.carBrand} ${rent.carModel}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Arrendatario: ${rent.renterName}",
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                            Text(
                              "Email: ${rent.renterEmail}",
                              style: const TextStyle(fontSize: 13, color: Colors.black54),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Fecha: $fechaStr",
                              style: const TextStyle(fontSize: 13, color: Colors.black54),
                            ),
                            Text(
                              "Precio: \$${rent.pricePerDay.toStringAsFixed(0)}/día",
                              style: const TextStyle(fontSize: 13, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),

                      //  Estado visual de la renta
                      Column(
                        children: [
                          Icon(
                            rent.active
                                ? Icons.timelapse_rounded
                                : Icons.check_circle_outline,
                            color: rent.active ? Colors.orange : Colors.green,
                            size: 28,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            rent.active ? "Activa" : "Finalizada",
                            style: TextStyle(
                              fontSize: 12,
                              color: rent.active ? Colors.orange : Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
