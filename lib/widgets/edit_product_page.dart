// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/models/product_model.dart';

class EditProductForm extends StatefulWidget {
  final Product product;

  const EditProductForm({super.key, required this.product});

  @override
  // ignore: library_private_types_in_public_api
  _EditProductFormState createState() => _EditProductFormState();
}

class _EditProductFormState extends State<EditProductForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _descriptionController = TextEditingController(text: widget.product.descripcion);
    if (widget.product.imageUrl.isNotEmpty) {
      _imageFile = File(widget.product.imageUrl);
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

  Future<void> _updateProduct() async {
    if (_formKey.currentState?.validate() ?? false) {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = prefs.getString('products') ?? '[]';
      final List<dynamic> productList = jsonDecode(productsJson);

      final updatedProduct = Product(
        id: widget.product.id,
        name: _nameController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        imageUrl: _imageFile?.path ?? widget.product.imageUrl,
        descripcion: _descriptionController.text, category: '', quantity: 1,
      );

      final index = productList.indexWhere((item) => item['id'] == widget.product.id);
      if (index != -1) {
        productList[index] = updatedProduct.toJson();
        await prefs.setString('products', jsonEncode(productList));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${updatedProduct.name} actualizado con éxito')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Producto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _updateProduct,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _imageFile == null
                  ? (widget.product.imageUrl.isNotEmpty
                      ? Image.file(File(widget.product.imageUrl))
                      : const Text('No image selected.'))
                  : Image.file(_imageFile!),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Cambiar Imagen'),
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