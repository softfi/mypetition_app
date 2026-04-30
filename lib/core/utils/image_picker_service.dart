import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:my_petition_app/core/utils/toast_message.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Show bottom sheet to select image source (Camera or Gallery)
  Future<File?> showImageSourceBottomSheet(BuildContext context) async {
    return await showModalBottomSheet<File?>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  'Select Image Source',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF202244),
                  ),
                ),
                const SizedBox(height: 20),

                // Camera Option
                _buildImageSourceOption(
                  context: context,
                  icon: Icons.camera_alt,
                  title: 'Camera',
                  subtitle: 'Take a new photo',
                  color: const Color(0xFF3762AA),
                  onTap: () async {
                    // final file = await pickImageWithPermission(ImageSource.camera);
                    final file = await _pickFromCamera();
                    if (context.mounted) {
                      Navigator.pop(context, file); // Close with the file result
                    }
                  },
                ),

                const SizedBox(height: 12),

                // Gallery Option
                _buildImageSourceOption(
                  context: context,
                  icon: Icons.photo_library,
                  title: 'Gallery',
                  subtitle: 'Choose from gallery',
                  color: const Color(0xFF0A6E4E),
                  onTap: () async {
                    // final file = await pickImageWithPermission(ImageSource.gallery);
                    final file = await _pickFromGallery();
                    if (context.mounted) {
                      Navigator.pop(context, file); // Close with the file result
                    }
                  },
                ),

                const SizedBox(height: 12),

                // Cancel Button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build image source option widget
  Widget _buildImageSourceOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF202244),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  // ── Camera: Robust Permission Handling ──
  Future<File?> _pickFromCamera() async {
    // Check current status first
    PermissionStatus status = await Permission.camera.status;

    if (status.isPermanentlyDenied) {
      _showPermissionDialog('Camera', Permission.camera);
      return null;
    }

    // Request if not granted
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }

    // Proceed if granted
    if (status.isGranted) {
      return _pickImage(ImageSource.camera);
    } else if (status.isDenied) {
      // Show snackbar only if user explicitly denied it
      AppSnackbar.warning('Please allow camera access to take a photo');
    }

    return null;
  }

  // ── Gallery: Robust Permission Handling ──
  Future<File?> _pickFromGallery() async {
    // For Android 13+ and iOS, handling permissions for gallery can be complex.
    // Modern image_picker versions often handle this, but checking status is safer.
    
    PermissionStatus status;
    if (Platform.isAndroid) {
      // Check for Android 13+ (SDK 33)
      final sdkInt = await _getAndroidVersion();
      if (sdkInt >= 33) {
        status = await Permission.photos.status;
        if (status.isPermanentlyDenied) {
          _showPermissionDialog('Gallery', Permission.photos);
          return null;
        }
        if (!status.isGranted) {
          status = await Permission.photos.request();
        }
      } else {
        status = await Permission.storage.status;
        if (status.isPermanentlyDenied) {
          _showPermissionDialog('Storage', Permission.storage);
          return null;
        }
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
      }
    } else {
      // iOS
      status = await Permission.photos.status;
      if (status.isPermanentlyDenied) {
        _showPermissionDialog('Photos', Permission.photos);
        return null;
      }
      // Note: On iOS, .request() might not be needed as image_picker handles it,
      // but if status is Denied (not permanently), we can request.
      if (status.isDenied) {
        status = await Permission.photos.request();
      }
    }

    // Procced if granted or limited (iOS)
    if (status.isGranted || status.isLimited) {
      return _pickImage(ImageSource.gallery);
    }

    return _pickImage(ImageSource.gallery); // Fallback to let image_picker handle it
  }

  // Common image picking logic
  Future<File?> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        debugPrint('✅ Image picked: ${pickedFile.path}');
        return File(pickedFile.path);
      }

      debugPrint('⚠️ No image selected');
      return null;
    } catch (e) {
      debugPrint('❌ Image picker error: $e');
      AppSnackbar.error('Failed to pick image. Please try again.');
      return null;
    }
  }



  /// Request and check permissions before picking image
  Future<File?> pickImageWithPermission(ImageSource source) async {
    try {
      // Request permission based on source
      PermissionStatus permission;

      if (source == ImageSource.camera) {
        permission = await Permission.camera.request();
        if (permission.isDenied || permission.isPermanentlyDenied) {
          _showPermissionDialog('Camera', Permission.camera);
          return null;
        }
      } else {
        // For Android 13+ (API 33+), use photos permission
        // For older versions, use storage permission
        if (Platform.isAndroid) {
          final androidInfo = await _getAndroidVersion();
          if (androidInfo >= 33) {
            permission = await Permission.photos.request();
          } else {
            permission = await Permission.storage.request();
          }
        } else {
          permission = await Permission.photos.request();
        }

        if (permission.isDenied || permission.isPermanentlyDenied) {
          _showPermissionDialog('Gallery',
              Platform.isAndroid ? Permission.storage : Permission.photos);
          return null;
        }
      }

      // Pick image
      return await pickImage(source);

    } on PlatformException catch (e) {
      debugPrint('PlatformException: ${e.message}');
      AppSnackbar.error('Failed to access ${source == ImageSource.camera ? 'camera' : 'gallery'}. Please try again.');
      return null;
    } catch (e) {
      debugPrint('Error picking image: $e');
      AppSnackbar.error('An unexpected error occurred');
      return null;
    }
  }

  /// Get Android SDK version
  Future<int> _getAndroidVersion() async {
    if (!Platform.isAndroid) return 0;

    try {
      // You can use device_info_plus package or handle it differently
      return 33; // Default to newer version for safety
    } catch (e) {
      return 33;
    }
  }

  /// Show permission dialog
  void _showPermissionDialog(String feature, Permission permission) {
    Get.dialog(
      AlertDialog(
        title: Text('$feature Permission Required'),
        content: Text(
          'Please grant $feature permission to use this feature. You can enable it in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Pick image from the specified source
  Future<File?> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        debugPrint('✅ Image picked successfully: ${pickedFile.path}');
        return File(pickedFile.path);
      }

      debugPrint('⚠️ No image selected');
      return null;
    } on PlatformException catch (e) {
      debugPrint('❌ PlatformException while picking image: ${e.code} - ${e.message}');

      if (e.code == 'camera_access_denied' || e.code == 'photo_access_denied') {
        AppSnackbar.warning('Please grant permission to access ${source == ImageSource.camera ? 'camera' : 'photos'}');
      } else {
        AppSnackbar.error('Failed to pick image. Please try again.');
      }
      return null;
    } catch (e) {
      debugPrint('❌ Unexpected error picking image: $e');
      AppSnackbar.error('An unexpected error occurred');
      return null;
    }
  }
}


