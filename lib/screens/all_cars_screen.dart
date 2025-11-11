import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'car_detail_screen.dart';

class AllCarsScreen extends StatefulWidget {
  const AllCarsScreen({super.key});

  @override
  State<AllCarsScreen> createState() => _AllCarsScreenState();
}

class _AllCarsScreenState extends State<AllCarsScreen> {
  String _searchText = '';
  String _selectedCategory = 'Todos';
  bool _showOnlyMyCars = false;

  final List<String> _categories = ['Todos', 'Sedan', 'SUV', 'Pickup', 'Deportivo'];

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar Autos'),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            icon: Icon(
              _showOnlyMyCars ? Icons.person : Icons.public,
              color: Colors.white,
            ),
            tooltip: _showOnlyMyCars ? 'Mostrar todos los autos' : 'Mostrar solo mis autos',
            onPressed: () {
              setState(() => _showOnlyMyCars = !_showOnlyMyCars);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 Campo de búsqueda
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Buscar por marca o modelo',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                setState(() => _searchText = value.toLowerCase());
              },
            ),
          ),

          // 🧭 Dropdown de categoría
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(cat),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Filtrar por categoría',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                setState(() => _selectedCategory = value!);
              },
            ),
          ),
          const SizedBox(height: 10),

          // 🔄 StreamBuilder con Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('cars').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Error al cargar los autos.'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No hay autos registrados aún.'));
                }

                final cars = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final brand = (data['brand'] ?? '').toString().toLowerCase();
                  final model = (data['model'] ?? '').toString().toLowerCase();
                  final category = (data['category'] ?? 'Todos').toString();
                  final ownerId = data['ownerId'];

                  final matchesSearch = _searchText.isEmpty ||
                      brand.contains(_searchText) ||
                      model.contains(_searchText);

                  final matchesCategory = _selectedCategory == 'Todos' || category == _selectedCategory;

                  final matchesOwner = !_showOnlyMyCars ||
                      (currentUser != null && ownerId == currentUser.uid);

                  return matchesSearch && matchesCategory && matchesOwner;
                }).toList();

                if (cars.isEmpty) {
                  return const Center(child: Text('No se encontraron coincidencias.'));
                }

                return ListView.builder(
                  itemCount: cars.length,
                  itemBuilder: (context, index) {
                    final carData = cars[index].data() as Map<String, dynamic>;

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: carData['imageUrl'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  carData['imageUrl'],
                                  width: 70,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.directions_car, size: 50, color: Colors.grey),
                        title: Text(
                          '${carData['brand']} ${carData['model']}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text('Categoría: ${carData['category'] ?? 'Sin categoría'}'),

                        // ✅ Abrir detalle al tocar
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CarDetailScreen(carData: carData),
                            ),
                          );
                        },
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
