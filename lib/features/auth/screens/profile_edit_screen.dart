import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:developer' as developer;
import '../../../core/api/api_client.dart';
import '../auth_provider.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  File? _imageFile;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      developer.log('Starting image picker...');

      // Request permissions
      if (Platform.isAndroid) {
        developer.log('Checking permissions...');

        // Check if we have the required permissions
        bool hasPermission = false;

        if (await Permission.camera.isGranted &&
            (await Permission.photos.isGranted ||
                await Permission.storage.isGranted)) {
          hasPermission = true;
          developer.log('All required permissions already granted');
        } else {
          developer.log('Requesting permissions...');

          // Request permissions
          final cameraResult = await Permission.camera.request();
          final photosResult = await Permission.photos.request();
          final storageResult = await Permission.storage.request();

          hasPermission = cameraResult.isGranted &&
              (photosResult.isGranted || storageResult.isGranted);

          developer.log(
              'Permission results - Camera: $cameraResult, Photos: $photosResult, Storage: $storageResult');
        }

        if (!hasPermission) {
          developer.log('Required permissions not granted');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    const Text('Camera and gallery permissions are required'),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Settings',
                  onPressed: () => openAppSettings(),
                ),
              ),
            );
          }
          return;
        }
      }

      developer.log('All permissions granted, showing source selection...');

      // Show dialog to choose between gallery and camera
      if (!mounted) return;
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Image Source'),
          content: const Text('Choose where to pick the image from:'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              child: const Text('Gallery'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              child: const Text('Camera'),
            ),
          ],
        ),
      );

      if (source == null) {
        developer.log('User cancelled source selection');
        return;
      }

      developer.log('Selected source: $source, opening image picker...');

      final ImagePicker picker = ImagePicker();
      XFile? picked;

      // Try the simplest possible call first
      try {
        picked = await picker.pickImage(source: source);
        developer.log('Image picked successfully with basic call');
      } catch (e) {
        developer.log('Basic pickImage failed: $e');
        // If basic call fails, try with quality setting
        try {
          picked = await picker.pickImage(
            source: source,
            imageQuality: 50,
          );
          developer.log('Image picked with quality setting');
        } catch (e2) {
          developer.log('Quality pickImage also failed: $e2');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Image picker failed. Error: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      if (picked != null) {
        developer.log('Image selected: ${picked.path}');
        try {
          final imageFile = File(picked.path);
          if (await imageFile.exists()) {
            developer.log('Image file exists and is accessible');
            developer.log('Setting image file in state...');
            setState(() => _imageFile = imageFile);
            developer.log('Image file set successfully');
          } else {
            developer.log('Image file does not exist at path: ${picked.path}');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Selected image file could not be accessed'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } catch (e) {
          developer.log('Error creating/accessing File: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error accessing image: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        developer.log('No image was selected (user cancelled)');
      }
    } catch (e, stackTrace) {
      developer.log('Image picker error: $e');
      developer.log('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Failed to pick image: ${e.toString().split(':').first}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _uploadImage(File file) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(file.path, filename: fileName),
      });
      final res = await ApiClient.dio.post('/upload/general', data: formData);
      return res.data['url'] as String?;
    } catch (e) {
      developer.log('Image upload error: $e');
      rethrow;
    }
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    if (name.isEmpty) return;

    developer.log('Starting save process...');
    developer
        .log('Name: $name, Phone: $phone, Has image: ${_imageFile != null}');

    setState(() => _uploading = true);
    try {
      String? imageUrl;
      if (_imageFile != null) {
        developer.log('Uploading image...');
        imageUrl = await _uploadImage(_imageFile!);
        developer.log('Image uploaded successfully: $imageUrl');
      } else {
        developer.log('No image to upload');
      }

      final auth = context.read<AuthProvider>();
      developer.log('Updating profile...');
      final ok = await auth.updateProfile(
        name: name,
        phone: phone.isNotEmpty ? phone : null,
        imageUrl: imageUrl,
      );

      developer.log('Profile update result: $ok');

      if (!mounted) return;
      if (ok) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Color(0xFF34C759),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.error ?? 'Update failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      developer.log('Save error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Something went wrong'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final loading = context.watch<AuthProvider>().isLoading || _uploading;

    developer.log(
        'Building ProfileEditScreen - hasImageFile: ${_imageFile != null}, userImageUrl: ${user?.imageUrl}');

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B3EE6),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Edit Profile',
            style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          TextButton(
            onPressed: loading ? null : _save,
            child: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('Save',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // ── Avatar ──
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE8ECFF),
                        border: Border.all(
                            color: const Color(0xFF2B3EE6), width: 2),
                      ),
                      child: ClipOval(
                        child: _imageFile != null
                            ? Image.file(_imageFile!,
                                fit: BoxFit.cover,
                                key: ValueKey(_imageFile!.path))
                            : user?.imageUrl != null
                                ? Image.network(
                                    user!.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                        Icons.person,
                                        color: Color(0xFF2B3EE6),
                                        size: 50),
                                  )
                                : const Icon(Icons.person,
                                    color: Color(0xFF2B3EE6), size: 50),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2B3EE6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text('Tap to change photo',
                style: TextStyle(fontSize: 12, color: Color(0xFF888888))),
            const SizedBox(height: 28),

            // ── Fields ──
            _Field(
              label: 'Full Name',
              controller: _nameCtrl,
              icon: Icons.person_outline,
              inputType: TextInputType.name,
            ),
            const SizedBox(height: 14),
            _Field(
              label: 'Phone Number',
              controller: _phoneCtrl,
              icon: Icons.phone_outlined,
              inputType: TextInputType.phone,
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11)
              ],
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B3EE6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Save Changes',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType inputType;
  final List<TextInputFormatter>? formatters;

  const _Field({
    required this.label,
    required this.controller,
    required this.icon,
    required this.inputType,
    this.formatters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        inputFormatters: formatters,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF888888), fontSize: 13),
          prefixIcon: Icon(icon, color: const Color(0xFF2B3EE6), size: 20),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
