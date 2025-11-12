import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/car_model.dart';
import '../services/car_service.dart';
import 'add_edit_car_screen.dart';

class MyCarsScreen extends StatelessWidget {
  const MyCarsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user!;
    final carService = CarService();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Mis carros"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: "Publicar nuevo carro",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditCarScreen(userId: user.uid),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<CarModel>>(
        stream: carService.getCarsByUser(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.redAccent));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No tienes carros registrados 😕",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          final cars = snapshot.data!;

          return ListView.builder(
            itemCount: cars.length,
            itemBuilder: (context, i) {
              final car = cars[i];
              final rentado = car.available == false;

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: car.imageUrl != null && car.imageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            car.imageUrl!,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported,
                                    size: 40, color: Colors.grey),
                          ),
                        )
                      : const Icon(Icons.directions_car, size: 40),

                  title: Text(
                    "${car.brand} ${car.model}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),

                  subtitle: Text(
                    rentado
                        ? "🚘 Rentado actualmente"
                        : "Año: ${car.year} • \$${car.pricePerDay.toStringAsFixed(0)}/día",
                    style: TextStyle(
                      fontSize: 14,
                      color: rentado ? Colors.redAccent : Colors.black54,
                      fontWeight: rentado ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),

                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) async {
                      // Bloquear actualizar si está rentado
                      if (value == 'update') {
                        if (rentado) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "⚠️ No puedes actualizar un carro rentado actualmente."),
                              backgroundColor: Colors.orangeAccent,
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddEditCarScreen(
                                userId: user.uid,
                                car: car,
                              ),
                            ),
                          );
                        }
                      } 
                      // Bloquear eliminar si está rentado
                      else if (value == 'delete' && rentado) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              " No puedes eliminar un carro que está rentado.",
                            ),
                            backgroundColor: Colors.orangeAccent,
                          ),
                        );
                      } 
                      // Eliminar si no está rentado
                      else if (value == 'delete' && !rentado) {
                        await carService.deleteCar(car.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Carro eliminado correctamente."),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'update',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue),
                            SizedBox(width: 8),
                            Text("Actualizar publicación"),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text("Eliminar publicación"),
                          ],
                        ),
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
