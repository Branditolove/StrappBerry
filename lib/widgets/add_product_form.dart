// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/models/product_model.dart';

class AddProductForm extends StatefulWidget {
  const AddProductForm({super.key});

  @override
  _AddProductFormState createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _imageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _addProduct() async {
    if (_formKey.currentState?.validate() ?? false) {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = prefs.getString('products') ?? '[]';
      final List<dynamic> productList = jsonDecode(productsJson);

      final newProduct = Product(
        id: DateTime.now().toString(),
        name: _nameController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        imageUrl: _imageFile?.path ?? '',
        descripcion: _descriptionController.text, category: '',
      );

      productList.add(newProduct.toJson());
      await prefs.setString('products', jsonEncode(productList));

      // Clear the form
      _nameController.clear();
      _priceController.clear();
      _descriptionController.clear();
      setState(() {
        _imageFile = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${newProduct.name} agregado con éxito')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Producto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _addProduct,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _imageFile == null
                  ? const Text('No image selected.')
                  : Image.file(_imageFile!),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Seleccionar Imagen'),
                  ),
                ],
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el nombre del producto';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el precio del producto';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor, ingrese un número válido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
