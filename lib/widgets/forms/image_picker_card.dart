import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:path/path.dart';

class ImagePickerCard extends StatelessWidget {
  final File? selectedImage;
  final Function(File) onImagePicked;
  final Function() onImageRemoved;

  const ImagePickerCard({
    super.key,
    required this.selectedImage,
    required this.onImagePicked,
    required this.onImageRemoved,
  });

  Future<void> _pickImage(BuildContext context) async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        onImagePicked(File(image.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Artwork Image',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildImageSection(context),
            if (selectedImage != null) ...[
              const SizedBox(height: 16),
              _buildImageActions(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child:
          selectedImage != null
              ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(selectedImage!, fit: BoxFit.cover),
              )
              : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No image selected',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(context),
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Select Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildImageActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () => _pickImage(context as BuildContext),
          icon: const Icon(Icons.photo_library),
          label: const Text('Change Image'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: onImageRemoved,
          icon: const Icon(Icons.delete),
          label: const Text('Remove'),
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
        ),
      ],
    );
  }
}
