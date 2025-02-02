import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../widgets/common/animated_text_field.dart';
import '../../services/menu_service.dart';
import '../../models/menu.dart';
import '../../models/stand/create_menu.dart';
import '../../models/stand/update_menu.dart';

// ignore: constant_identifier_names
enum MenuType { FOOD, DRINK }

class MenuFormPage extends StatefulWidget {
  final Menu? menu;

  const MenuFormPage({super.key, this.menu});

  @override
  State<MenuFormPage> createState() => _MenuFormPageState();
}

class _MenuFormPageState extends State<MenuFormPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  MenuType _selectedType = MenuType.FOOD;
  File? _selectedPhoto;
  bool get isEditMode => widget.menu != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _nameController.text = widget.menu?.name ?? '';
      _priceController.text = widget.menu?.price.toString() ?? '';
      _descriptionController.text = widget.menu?.description ?? '';
      _selectedType =
          widget.menu?.type == 'FOOD' ? MenuType.FOOD : MenuType.DRINK;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Menu' : 'Add New Menu'),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImagePicker(currentImageUrl: widget.menu?.photo),
              const SizedBox(height: 24),
              AnimatedTextField(
                controller: _nameController,
                label: 'Menu Name',
                icon: LucideIcons.fileText,
                validator: (value) =>
                    value?.isEmpty == true ? 'Please enter menu name' : null,
              ),
              const SizedBox(height: 16),
              AnimatedTextField(
                controller: _priceController,
                label: 'Price',
                icon: LucideIcons.dollarSign,
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty == true ? 'Please enter price' : null,
              ),
              const SizedBox(height: 16),
              AnimatedTextField(
                controller: _descriptionController,
                label: 'Description (Optional)',
                icon: LucideIcons.text,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<MenuType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Menu Type',
                  prefixIcon: Icon(LucideIcons.listFilter),
                ),
                items: MenuType.values
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.name),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                child: _isSubmitting
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(isEditMode ? 'Updating...' : 'Adding...'),
                        ],
                      )
                    : Text(isEditMode ? 'Update Menu' : 'Add Menu'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker({String? currentImageUrl}) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_selectedPhoto != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _selectedPhoto!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              )
            else if (currentImageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  currentImageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildPlaceholderImage(),
                ),
              ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(12),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: (_selectedPhoto != null || currentImageUrl != null)
                          ? Colors.black.withValues(alpha: .1)
                          : Colors.transparent,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_selectedPhoto == null && currentImageUrl == null)
                            _buildUploadPrompt()
                          else
                            _buildChangePhotoPrompt(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_selectedPhoto != null)
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(LucideIcons.x),
                  onPressed: () => setState(() => _selectedPhoto = null),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    shadowColor: Colors.black26,
                    elevation: 4,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadPrompt() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(LucideIcons.image,
            size: 48, color: isEditMode ? Colors.grey[400] : Colors.red[300]),
        const SizedBox(height: 8),
        Text(
          'Upload Photo',
          style: TextStyle(
            color: isEditMode ? Colors.grey[600] : Colors.red[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isEditMode ? 'Click to select' : '* Required - Click to select',
              style: TextStyle(
                color: isEditMode ? Colors.grey[400] : Colors.red[400],
                fontSize: 12,
              ),
            ),
            if (!isEditMode) ...[
              const SizedBox(width: 4),
              Icon(LucideIcons.asterisk, size: 8, color: Colors.red[400])
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildChangePhotoPrompt() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.imagePlus, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            'Change Photo',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          LucideIcons.image,
          size: 40,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedPhoto = File(pickedFile.path);
      });
    }
  }

  bool _isSubmitting = false;
  void _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!isEditMode && _selectedPhoto == null) {
        _showSnackbar('Please select a photo', isSuccess: false);
        return;
      }

      setState(() => _isSubmitting = true);
      final menuService = Provider.of<MenuService>(context, listen: false);

      try {
        if (isEditMode) {
          final updateMenuDto = UpdateMenuDto(
            name: _nameController.text,
            price: int.parse(_priceController.text),
            description: _descriptionController.text,
            type: _selectedType.name,
          );

          final response = await menuService.updateMenu(
            widget.menu!.id,
            updateMenuDto,
            photoFile: _selectedPhoto,
          );

          if (response.isSuccess) {
            _showSnackbar('Menu updated successfully', isSuccess: true);
            if (!mounted) return;
            Navigator.pop(context, true);
          } else {
            // ignore: dead_null_aware_expression
            _showSnackbar(response.message ?? 'Failed to update menu',
                isSuccess: false);
          }
        } else {
          final createMenuDto = CreateMenuDto(
            name: _nameController.text,
            price: int.parse(_priceController.text),
            description: _descriptionController.text,
            type: _selectedType.name,
          );

          final response =
              await menuService.createMenu(createMenuDto, _selectedPhoto!);

          if (response.isSuccess) {
            _showSnackbar('Menu added successfully', isSuccess: true);
            if (!mounted) return;
            Navigator.pop(context, true);
          } else {
            // ignore: dead_null_aware_expression
            _showSnackbar(response.message ?? 'Failed to add menu',
                isSuccess: false);
          }
        }
      } catch (e) {
        _showSnackbar('An error occurred', isSuccess: false);
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSnackbar(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
