import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/rental_model.dart';
import '../services/rental_service.dart';
import '../services/car_service.dart';

class MyRentalsScreen extends StatefulWidget {
  const MyRentalsScreen({super.key});

  @override
  State<MyRentalsScreen> createState() => _MyRentalsScreenState();
}

class _MyRentalsScreenState extends State<MyRentalsScreen> {
  bool showHistory = false;
  final rentalService = RentalService();
  final carService = CarService();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user!;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Mis rentas 🚘"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Switch de historial
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SwitchListTile(
              title: const Text(
                "Mostrar historial completo",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              activeColor: Colors.redAccent,
              value: showHistory,
              onChanged: (v) {
                setState(() => showHistory = v);
              },
            ),
          ),

          // Lista de rentas
          Expanded(
            child: StreamBuilder<List<RentalModel>>(
              stream: rentalService.getRentalsByUser(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.redAccent),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      "Error al cargar las rentas.",
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "No tienes rentas registradas 😕",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  );
                }

                // Filtrar según el switch
                final allRentals = snapshot.data!;
                final rentals =
                    showHistory ? allRentals : allRentals.where((r) => r.active).toList();

                if (rentals.isEmpty) {
                  return const Center(
                    child: Text(
                      "No hay rentas activas actualmente 🚗",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: rentals.length,
                  itemBuilder: (context, i) {
                    final rent = rentals[i];
                    final fecha = rent.rentDate;
                    final fechaStr =
                        "${fecha.day}/${fecha.month}/${fecha.year}  "
                        "${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}";

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: rent.carImage.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  rent.carImage,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.directions_car, size: 40, color: Colors.grey),

                        title: Text(
                          "${rent.carBrand} ${rent.carModel}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          "Fecha: $fechaStr\n"
                          "Precio: \$${rent.pricePerDay.toStringAsFixed(0)}/día",
                          style: const TextStyle(fontSize: 14, color: Colors.black54),
                        ),

                        // Opciones de cada renta
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) async {
                            if (value == 'finish' && rent.active) {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Finalizar renta"),
                                  content: const Text(
                                    "¿Deseas finalizar esta renta? El carro volverá a estar disponible.",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text("Cancelar"),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent),
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text("Finalizar"),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await rentalService.finishRental(rent.id);
                                await carService.markAsAvailable(rent.carId);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "✅ Renta finalizada y carro disponible nuevamente."),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } else if (value == 'delete') {
                              if (rent.active) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text("⚠️ No puedes eliminar una renta activa."),
                                    backgroundColor: Colors.orangeAccent,
                                  ),
                                );
                              } else {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Eliminar renta"),
                                    content: const Text(
                                        "¿Estás seguro de eliminar esta renta del historial?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text("Cancelar"),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.redAccent),
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text("Eliminar"),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await rentalService.deleteRental(rent.id);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text("🗑️ Renta eliminada del historial."),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          itemBuilder: (context) => [
                            if (rent.active)
                              const PopupMenuItem(
                                value: 'finish',
                                child: Row(
                                  children: [
                                    Icon(Icons.stop_circle, color: Colors.orange),
                                    SizedBox(width: 8),
                                    Text("Finalizar renta"),
                                  ],
                                ),
                              ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text("Eliminar del historial"),
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
          ),
        ],
      ),
    );
  }
}
