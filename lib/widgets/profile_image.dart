import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:music_app/utils/app_colors.dart';

class ProfileImage extends StatefulWidget {
  final String? imageUrl;
  final double size;
  final bool editable;

  final Future<String?> Function(File imageFile)? onUpload;

  const ProfileImage({
    super.key,
    this.imageUrl,
    this.size = 120,
    this.editable = true,
    this.onUpload,
  });

  @override
  State<ProfileImage> createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  final ImagePicker _picker = ImagePicker();

  File? _localImage;
  String? _networkImage;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _networkImage = widget.imageUrl;
  }

  ImageProvider? get _imageProvider {
    if (_localImage != null) {
      return FileImage(_localImage!);
    }
    if (_networkImage != null && _networkImage!.isNotEmpty) {
      return NetworkImage(_networkImage!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Profile Image
        Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: _imageProvider != null
                ? DecorationImage(image: _imageProvider!, fit: BoxFit.cover)
                : null,
            color: Colors.grey.shade800,
            border: Border.all(color: AppColors.primaryColor, width: 2),
          ),
          child: _imageProvider == null
              ? Icon(
                  Icons.person,
                  size: widget.size / 2,
                  color: Colors.grey.shade400,
                )
              : null,
        ),

        // Camera Button
        if (widget.editable)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _loading ? null : _showImagePickerBottomSheet,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
              ),
            ),
          ),
      ],
    );
  }

  // ================== BOTTOM SHEET ==================

  void _showImagePickerBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag indicator
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Change Profile Picture',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),

            const SizedBox(height: 24),

            _buildOptionTile(
              title: 'Take Photo',
              icon: Icons.camera_alt_outlined,
              onTap: () async {
                Get.back();
                await _pickImage(ImageSource.camera);
              },
            ),

            const SizedBox(height: 12),

            _buildOptionTile(
              title: 'Choose From Gallery',
              icon: Icons.photo_library_outlined,
              onTap: () async {
                Get.back();
                await _pickImage(ImageSource.gallery);
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildOptionTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryColor, size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  // ================== IMAGE PICK & UPLOAD ==================

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (pickedFile == null) return;

    setState(() {
      _localImage = File(pickedFile.path);
      _loading = true;
    });

    if (widget.onUpload != null) {
      final uploadedUrl = await widget.onUpload!(_localImage!);
      if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
        setState(() {
          _networkImage = uploadedUrl;
        });
      }
    }

    setState(() {
      _localImage = null;
      _loading = false;
    });
  }
}
