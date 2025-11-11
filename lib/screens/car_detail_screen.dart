import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/rental_model.dart';
import '../models/comment_model.dart';
import '../services/rental_service.dart';
import '../services/car_service.dart';
import '../services/comment_service.dart';

class CarDetailScreen extends StatelessWidget {
  final Map<String, dynamic> carData;

  const CarDetailScreen({super.key, required this.carData});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user!;
    final rentalService = RentalService();
    final carService = CarService();
    final commentService = CommentService();
    final commentCtrl = TextEditingController();

    // 🧩 Datos del carro
    final brand = carData['brand'] ?? 'Sin marca';
    final model = carData['model'] ?? '';
    final year = carData['year']?.toString() ?? 'N/A';
    final price = (carData['pricePerDay'] ?? 0).toDouble();
    final available = carData['available'] ?? false;
    final imageUrl = carData['imageUrl'];
    final carId = carData['id'] ?? '';
    final ownerId = carData['ownerId'] ?? '';
    final category = carData['category'] ?? 'Sin categoría';
    final description = carData['description'] ?? 'Sin descripción';

    final isOwner = ownerId == user.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('$brand $model'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🖼️ Imagen del carro
            imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 250,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : Container(
                    height: 250,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.directions_car,
                      size: 80,
                      color: Colors.grey,
                    ),
                  ),

            const SizedBox(height: 20),

            // 🧾 Información del carro
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$brand $model',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20, color: Colors.redAccent),
                      const SizedBox(width: 6),
                      Text('Año: $year',
                          style: const TextStyle(fontSize: 16, color: Colors.black54)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.category, size: 20, color: Colors.redAccent),
                      const SizedBox(width: 6),
                      Text('Categoría: $category',
                          style: const TextStyle(fontSize: 16, color: Colors.black54)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.attach_money, size: 20, color: Colors.redAccent),
                      const SizedBox(width: 6),
                      Text(
                        'Precio por día: \$${price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        available ? Icons.check_circle : Icons.cancel,
                        color: available ? Colors.green : Colors.redAccent,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        available ? 'Disponible para renta' : 'No disponible',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Divider(),

                  // 📝 Descripción
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),

                  const SizedBox(height: 25),

                  // ⚠️ Si el carro es del mismo usuario
                  if (isOwner)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text(
                        "⚠️ No puedes rentar tu propio vehículo.",
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                  // 🔑 Botón de rentar
                  ElevatedButton.icon(
                    onPressed: (!available || isOwner)
                        ? null
                        : () async {
                            try {
                              final rental = RentalModel(
                                id: const Uuid().v4(),
                                userId: user.uid,
                                ownerId: ownerId,
                                carId: carId,
                                carBrand: brand,
                                carModel: model,
                                carImage: imageUrl ?? '',
                                pricePerDay: price,
                                rentDate: DateTime.now(),
                                renterName: user.name,
                                renterEmail: user.email,
                              );

                              await rentalService.rentCar(rental);
                              await carService.markAsRented(carId, user.uid);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("🚗 ¡Carro rentado correctamente!"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Error al rentar el carro: $e"),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          },
                    icon: const Icon(Icons.key),
                    label: Text(
                      isOwner
                          ? "No puedes rentar tu propio carro"
                          : "Rentar ahora",
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      disabledBackgroundColor: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 💬 Sección de comentarios en vivo
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            "💬 Comentarios en vivo",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),

                        // 🔄 StreamBuilder de comentarios
                        StreamBuilder<List<CommentModel>>(
                          stream: commentService.getComments(carId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                  child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: CircularProgressIndicator()));
                            }

                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  "No hay comentarios aún. ¡Sé el primero en comentar!",
                                  style: TextStyle(color: Colors.black54),
                                ),
                              );
                            }

                            final comments = snapshot.data!;

                            return ListView.builder(
                              itemCount: comments.length,
                              shrinkWrap: true,
                              reverse: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, i) {
                                final c = comments[i];
                                return ListTile(
                                  leading: const Icon(Icons.person, color: Colors.redAccent),
                                  title: Text(
                                    c.userName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  subtitle: Text(c.message),
                                  trailing: Text(
                                    "${c.createdAt.hour.toString().padLeft(2, '0')}:${c.createdAt.minute.toString().padLeft(2, '0')}",
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                );
                              },
                            );
                          },
                        ),

                        const Divider(),

                        // 📝 Campo de texto y botón enviar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: commentCtrl,
                                  decoration: const InputDecoration(
                                    hintText: "Escribe un comentario...",
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.send, color: Colors.redAccent),
                                onPressed: () async {
                                  if (commentCtrl.text.trim().isEmpty) return;

                                  final newComment = CommentModel(
                                    id: const Uuid().v4(),
                                    userId: user.uid,
                                    userName: user.name,
                                    message: commentCtrl.text.trim(),
                                    createdAt: DateTime.now(),
                                  );

                                  await commentService.addComment(carId, newComment);
                                  commentCtrl.clear();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
