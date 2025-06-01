import 'dart:io';

import 'package:flutter/material.dart';
import 'package:khat_husseini/models/artwork_model.dart';
import 'package:khat_husseini/widgets/forms/image_picker_card.dart';
import 'package:khat_husseini/widgets/forms/custom_form_field.dart'; // Import the custom field

class AddItemScreen extends StatefulWidget {
  final Function(Artwork) onAddArtwork;

  const AddItemScreen({super.key, required this.onAddArtwork});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  String selectedCategory = 'Banner';
  bool isFeatured = false;
  File? _selectedImage;

  final List<String> categories = [
    'Banner',
    'Flag',
    'historical',
    'Paintings',
    'portraits',
    'shrines',
    'traditional',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _addArtwork() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      _showSnackBar('Please select an image', Colors.red);
      return;
    }

    final newArtwork = Artwork(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      imageUrl: _selectedImage!.path,
      category: selectedCategory,
      price: double.parse(_priceController.text.trim()),
      isFeatured: isFeatured,
    );

    widget.onAddArtwork(newArtwork);
    _showSnackBar('Artwork added successfully!', Colors.green);
    Navigator.pop(context);
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Artwork'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Using factory constructors for cleaner code
              CustomFormField.title(controller: _titleController),
              const SizedBox(height: 16),
              CustomFormField.description(controller: _descriptionController),
              const SizedBox(height: 16),
              ImagePickerCard(
                selectedImage: _selectedImage,
                onImagePicked:
                    (image) => setState(() => _selectedImage = image),
                onImageRemoved: () => setState(() => _selectedImage = null),
              ),
              const SizedBox(height: 16),
              CustomFormField.price(controller: _priceController),
              const SizedBox(height: 16),
              _buildCategoryDropdown(),
              const SizedBox(height: 16),
              _buildFeaturedToggle(),
              const SizedBox(height: 32),
              _buildAddButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.category),
      ),
      items:
          categories
              .map(
                (category) =>
                    DropdownMenuItem(value: category, child: Text(category)),
              )
              .toList(),
      onChanged: (value) => setState(() => selectedCategory = value!),
    );
  }

  Widget _buildFeaturedToggle() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        title: const Text('Featured Artwork'),
        subtitle: const Text('Display in featured carousel'),
        value: isFeatured,
        onChanged: (value) => setState(() => isFeatured = value),
        secondary: const Icon(Icons.star),
        activeColor: Colors.teal,
      ),
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton.icon(
      onPressed: _addArtwork,
      icon: const Icon(Icons.add),
      label: const Text('Add Artwork'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16),
      ),
    );
  }
}
