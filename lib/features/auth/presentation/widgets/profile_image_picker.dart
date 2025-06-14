import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/theme/app_colors.dart';

class ProfileImagePicker extends StatelessWidget {
  final File? profileImage;
  final Function(File) onImagePicked;
  final double? size; // diameter

  const ProfileImagePicker({
    super.key,
    this.profileImage,
    required this.onImagePicked,
    this.size,
  });

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        onImagePicked(File(image.path));
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final diameter = size ?? MediaQuery.of(context).size.width * 0.3;
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          Container(
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
              image: profileImage != null
                  ? DecorationImage(
                      image: FileImage(profileImage!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: profileImage == null
                ? Icon(
                    Icons.person,
                    size: diameter * 0.5,
                    color: Colors.grey[400],
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: diameter * 0.3,
              height: diameter * 0.3,
              decoration: BoxDecoration(
                color: AppColors.logoOrange,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: diameter * 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 