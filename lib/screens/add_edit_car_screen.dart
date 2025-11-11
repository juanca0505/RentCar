import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/car_model.dart';
import '../services/car_service.dart';

class AddEditCarScreen extends StatefulWidget {
  final String userId;
  final CarModel? car;

  const AddEditCarScreen({super.key, required this.userId, this.car});

  @override
  State<AddEditCarScreen> createState() => _AddEditCarScreenState();
}

class _AddEditCarScreenState extends State<AddEditCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController(); // ✅ nuevo campo descripción
  String _selectedCategory = 'Sedan'; // ✅ nuevo campo categoría
  bool _available = true;
  File? _imageFile;
  final picker = ImagePicker();
  final carService = CarService();

  final List<String> _categories = ['Sedan', 'SUV', 'Pickup', 'Deportivo'];

  @override
  void initState() {
    super.initState();
    if (widget.car != null) {
      _brandCtrl.text = widget.car!.brand;
      _modelCtrl.text = widget.car!.model;
      _yearCtrl.text = widget.car!.year.toString();
      _priceCtrl.text = widget.car!.pricePerDay.toString();
      _available = widget.car!.available;
      _selectedCategory = widget.car!.category ?? 'Sedan';
      _descCtrl.text = widget.car!.description ?? '';
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _saveCar() async {
    if (!_formKey.currentState!.validate()) return;

    final id = widget.car?.id ?? const Uuid().v4();

    final car = CarModel(
      id: id,
      ownerId: widget.userId,
      brand: _brandCtrl.text.trim(),
      model: _modelCtrl.text.trim(),
      year: int.parse(_yearCtrl.text.trim()),
      pricePerDay: double.parse(_priceCtrl.text.trim()),
      available: _available,
      imageUrl: widget.car?.imageUrl,
      category: _selectedCategory, // ✅ nuevo
      description: _descCtrl.text.trim(), // ✅ nuevo
    );

    await carService.saveCar(car, imageFile: _imageFile);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.car == null
              ? "Carro publicado correctamente 🚗✅"
              : "Publicación actualizada correctamente 🔁"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.car == null ? "Agregar carro" : "Actualizar publicación"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : (widget.car?.imageUrl != null
                            ? NetworkImage(widget.car!.imageUrl!)
                            : null) as ImageProvider?,
                    child: _imageFile == null && widget.car?.imageUrl == null
                        ? const Icon(Icons.camera_alt, size: 40)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 🔹 Marca
              TextFormField(
                controller: _brandCtrl,
                decoration: const InputDecoration(labelText: "Marca"),
                validator: (v) => v!.isEmpty ? "Campo obligatorio" : null,
              ),
              const SizedBox(height: 10),

              // 🔹 Modelo
              TextFormField(
                controller: _modelCtrl,
                decoration: const InputDecoration(labelText: "Modelo"),
                validator: (v) => v!.isEmpty ? "Campo obligatorio" : null,
              ),
              const SizedBox(height: 10),

              // 🔹 Año
              TextFormField(
                controller: _yearCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Año"),
                validator: (v) => v!.isEmpty ? "Campo obligatorio" : null,
              ),
              const SizedBox(height: 10),

              // 🔹 Precio
              TextFormField(
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Precio por día"),
                validator: (v) => v!.isEmpty ? "Campo obligatorio" : null,
              ),
              const SizedBox(height: 10),

              // 🔹 Categoría
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: "Categoría del vehículo",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() => _selectedCategory = value!);
                },
              ),
              const SizedBox(height: 10),

              // 🔹 Descripción
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Descripción (opcional)",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              // 🔹 Disponible
              SwitchListTile(
                title: const Text("Disponible para renta"),
                value: _available,
                activeColor: Colors.redAccent,
                onChanged: (v) => setState(() => _available = v),
              ),
              const SizedBox(height: 20),

              // 🔘 Botón guardar
              ElevatedButton.icon(
                onPressed: _saveCar,
                icon: const Icon(Icons.save),
                label: Text(widget.car == null
                    ? "Publicar carro"
                    : "Actualizar publicación"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
