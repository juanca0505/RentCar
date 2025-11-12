import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // prefijo agregado
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart' as local_auth; // prefijo agregado

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameCtrl = TextEditingController();
  final cedulaCtrl = TextEditingController();
  final direccionCtrl = TextEditingController();
  final celularCtrl = TextEditingController();

  bool _isSaving = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<local_auth.AuthProvider>(context, listen: false).user;
    if (user != null) {
      nameCtrl.text = user.name;
      cedulaCtrl.text = user.cedula ?? '';
      direccionCtrl.text = user.direccion ?? '';
      celularCtrl.text = user.celular ?? '';
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(String uid) async {
    if (_imageFile == null) return null;

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pics')
          .child('$uid.jpg');
      await ref.putFile(_imageFile!);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error subiendo imagen: $e");
      return null;
    }
  }

  Future<void> _saveProfile() async {
    final authProvider = Provider.of<local_auth.AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user == null) return;

    final newName = nameCtrl.text.trim();
    final cedula = cedulaCtrl.text.trim();
    final direccion = direccionCtrl.text.trim();
    final celular = celularCtrl.text.trim();

    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El nombre no puede estar vacío")),
      );
      return;
    }

    setState(() => _isSaving = true);

    String? photoUrl = user.photoUrl;
    if (_imageFile != null) {
      final uploadedUrl = await _uploadImage(user.uid);
      if (uploadedUrl != null) {
        photoUrl = uploadedUrl;
      }
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'name': newName,
        'photoUrl': photoUrl,
        'cedula': cedula,
        'direccion': direccion,
        'celular': celular,
      });

      authProvider.user = UserModel(
        uid: user.uid,
        name: newName,
        email: user.email,
        photoUrl: photoUrl,
        cedula: cedula,
        direccion: direccion,
        celular: celular,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Perfil actualizado correctamente ✅")),
      );
    } catch (e) {
      print("Error guardando perfil: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al guardar los cambios ❌")),
      );
    }

    setState(() => _isSaving = false);
  }

  // 🔑 Cambiar contraseña (por correo)
  Future<void> _changePassword() async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await firebase_auth.FirebaseAuth.instance.sendPasswordResetEmail(
        email: user.email!,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Se envió un enlace de cambio de contraseña a tu correo electrónico.",
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al enviar el enlace.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<local_auth.AuthProvider>(context).user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("No hay usuario autenticado")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi perfil"),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Imagen de perfil
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : (user.photoUrl != null
                            ? NetworkImage(user.photoUrl!)
                            : const AssetImage('assets/default_avatar.png'))
                                as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(Icons.camera_alt, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // 🧍 Nombre
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: "Nombre completo",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // Cédula
            TextField(
              controller: cedulaCtrl,
              decoration: const InputDecoration(
                labelText: "Cédula",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),

            // Dirección
            TextField(
              controller: direccionCtrl,
              decoration: const InputDecoration(
                labelText: "Dirección de vivienda",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // Celular
            TextField(
              controller: celularCtrl,
              decoration: const InputDecoration(
                labelText: "Número de celular",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 15),

            // Correo (no editable)
            TextField(
              enabled: false,
              decoration: InputDecoration(
                labelText: "Correo electrónico",
                border: const OutlineInputBorder(),
                hintText: user.email,
              ),
            ),
            const SizedBox(height: 25),

            // Botón guardar
            _isSaving
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _saveProfile,
                    icon: const Icon(Icons.save),
                    label: const Text("Guardar cambios"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
            const SizedBox(height: 15),

            // Botón cambiar contraseña
            OutlinedButton.icon(
              onPressed: _changePassword,
              icon: const Icon(Icons.lock_reset, color: Colors.red),
              label: const Text(
                "Cambiar contraseña",
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
