import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/utils/theme/app_colors.dart';

class ProfileImagePicker extends StatefulWidget {
  final String? initialImageUrl;
  final Function(File?) onImageSelected;

  const ProfileImagePicker({
    Key? key,
    this.initialImageUrl,
    required this.onImageSelected,
  }) : super(key: key);

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  File? _selectedImage;

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        widget.onImageSelected(_selectedImage);
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          Container(
            width: 120.w,
            height: 120.h,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: ClipOval(
              child: Builder(
                builder: (context) {
                  // إذا كان هناك صورة محلية مختارة
                  if (_selectedImage != null) {
                    return Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                      width: 120.w,
                      height: 120.h,
                    );
                  }
                  // إذا كان هناك صورة من الإنترنت
                  if (widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty) {
                    return Image.network(
                      widget.initialImageUrl!,
                      fit: BoxFit.cover,
                      width: 120.w,
                      height: 120.h,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          size: 60.sp,
                          color: Colors.grey[400],
                        );
                      },
                    );
                  }
                  // إذا لم تكن هناك صورة
                  return Icon(
                    Icons.person,
                    size: 60.sp,
                    color: Colors.grey[400],
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: AppColors.logoOrange,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2.w,
                ),
              ),
              child: Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 