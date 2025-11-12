import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'add_edit_car_screen.dart';
import 'my_cars_screen.dart';
import 'all_cars_screen.dart';
import 'my_rentals_screen.dart';
import 'my_car_rentals_screen.dart'; // Nueva pantalla para propietarios

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "RentACar 🚗",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: "Cerrar sesión",
            onPressed: () async {
              await authProvider.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            )
          : FadeTransition(
              opacity: _fadeIn,
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Foto de perfil
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.redAccent.withOpacity(0.2),
                      backgroundImage: user.photoUrl != null
                          ? NetworkImage(user.photoUrl!)
                          : const AssetImage('assets/default_avatar.png')
                              as ImageProvider,
                    ),
                    const SizedBox(height: 20),

                    // Nombre y saludo
                    Text(
                      "Hola, ${user.name.split(' ').first} 👋",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user.email,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Menú principal
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildMenuCard(
                          icon: Icons.person,
                          color: Colors.orangeAccent,
                          text: "Mi perfil",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfileScreen(),
                              ),
                            );
                          },
                        ),
                        _buildMenuCard(
                          icon: Icons.directions_car_filled_rounded,
                          color: Colors.teal,
                          text: "Mis carros",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MyCarsScreen(),
                              ),
                            );
                          },
                        ),
                        _buildMenuCard(
                          icon: Icons.public_rounded,
                          color: Colors.blueAccent,
                          text: "Ver publicados",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AllCarsScreen(),
                              ),
                            );
                          },
                        ),
                        _buildMenuCard(
                          icon: Icons.history_edu_rounded,
                          color: Colors.deepPurple,
                          text: "Mis rentas",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MyRentalsScreen(),
                              ),
                            );
                          },
                        ),
                        _buildMenuCard(
                          icon: Icons.people_alt_rounded,
                          color: Colors.purpleAccent,
                          text: "Rentas de mis vehículos",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MyCarRentalsScreen(),
                              ),
                            );
                          },
                        ),
                        _buildMenuCard(
                          icon: Icons.settings_rounded,
                          color: Colors.grey,
                          text: "Configuración",
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Función en desarrollo 🔧'),
                                backgroundColor: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 60),

                    // Mensaje inferior
                    const Text(
                      "Explora, publica y renta vehículos de forma segura con RentACar.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black45, fontSize: 14),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

      // Botón flotante: Publicar carro
      floatingActionButton: FloatingActionButton.extended(
        onPressed: user == null
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditCarScreen(userId: user.uid),
                  ),
                );
              },
        backgroundColor: Colors.redAccent,
        icon: const Icon(Icons.add_circle_outline),
        label: const Text("Publicar carro"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // Card del menú principal
  Widget _buildMenuCard({
    required IconData icon,
    required Color color,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 45, color: color),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
