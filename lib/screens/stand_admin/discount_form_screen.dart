import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../../widgets/common/animated_text_field.dart';
import '../../services/discount_service.dart';
import '../../services/menu_service.dart';
import '../../models/stand/discount.dart';
import '../../models/menu.dart';
import '../../models/stand/create_discount.dart';
import '../../models/stand/update_discount.dart';

class DiscountFormPage extends StatefulWidget {
  final Discount? discount;

  const DiscountFormPage({super.key, this.discount});

  @override
  State<DiscountFormPage> createState() => _DiscountFormPageState();
}

class _DiscountFormPageState extends State<DiscountFormPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _percentageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  List<Menu> _availableMenus = [];
  List<Menu> _selectedMenus = [];
  bool _isLoadingMenus = false;
  bool _isSubmitting = false;

  bool get isEditMode => widget.discount != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _nameController.text = widget.discount?.name ?? '';
      _percentageController.text = widget.discount?.percentage.toString() ?? '';
      _startDate = widget.discount?.startDate ?? DateTime.now();
      _endDate = widget.discount?.endDate ??
          DateTime.now().add(const Duration(days: 7));
      _selectedMenus = widget.discount?.menus ?? [];
    }
    _loadMenus();
  }

  Future<void> _loadMenus() async {
    setState(() => _isLoadingMenus = true);
    final menuService = Provider.of<MenuService>(context, listen: false);
    final response = await menuService.getMenus();
    if (response.isSuccess && response.data != null) {
      setState(() {
        _availableMenus = response.data!;
        _isLoadingMenus = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Discount' : 'Add New Discount'),
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
              AnimatedTextField(
                controller: _nameController,
                label: 'Discount Name',
                icon: LucideIcons.tag,
                validator: (value) => value?.isEmpty == true
                    ? 'Please enter discount name'
                    : null,
              ),
              const SizedBox(height: 16),
              AnimatedTextField(
                controller: _percentageController,
                label: 'Percentage',
                icon: LucideIcons.percent,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty == true) return 'Please enter percentage';
                  final number = double.tryParse(value!);
                  if (number == null) return 'Please enter a valid number';
                  if (number <= 0 || number > 100) {
                    return 'Percentage must be between 0 and 100';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildDatePicker(
                label: 'Start Date',
                selectedDate: _startDate,
                onChanged: (date) => setState(() => _startDate = date),
              ),
              const SizedBox(height: 16),
              _buildDatePicker(
                label: 'End Date',
                selectedDate: _endDate,
                onChanged: (date) => setState(() => _endDate = date),
              ),
              const SizedBox(height: 24),
              _buildMenuSelection(),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                child: _isSubmitting
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(isEditMode ? 'Updating...' : 'Adding...'),
                        ],
                      )
                    : Text(isEditMode ? 'Update Discount' : 'Add Discount'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime selectedDate,
    required ValueChanged<DateTime> onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(LucideIcons.calendar),
        ),
        child: Text(
          DateFormat('MMM dd, yyyy').format(selectedDate),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }

  Widget _buildMenuSelection() {
    if (_isLoadingMenus) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Menus',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (_availableMenus.isEmpty)
          const Text('No menus available')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableMenus.map((menu) {
              final indexMenu =
                  _selectedMenus.indexWhere((item) => item.id == menu.id);
              final isSelected = indexMenu != -1;

              return FilterChip(
                label: Text(menu.name),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedMenus.add(menu);
                    } else {
                      _selectedMenus.removeAt(indexMenu);
                    }
                  });
                },
              );
            }).toList(),
          ),
      ],
    );
  }

  void _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedMenus.isEmpty) {
        _showSnackbar('Please select at least one menu', isSuccess: false);
        return;
      }

      if (_endDate.isBefore(_startDate)) {
        _showSnackbar('End date must be after start date', isSuccess: false);
        return;
      }

      setState(() => _isSubmitting = true);
      final discountService =
          Provider.of<DiscountService>(context, listen: false);

      try {
        if (isEditMode) {
          final updateDiscountDto = UpdateDiscountDto(
            name: _nameController.text,
            percentage: double.parse(_percentageController.text),
            startDate: _startDate,
            endDate: _endDate,
            menus: _selectedMenus.map((i) => i.id).toList(),
          );

          final response = await discountService.updateDiscount(
            widget.discount!.id,
            updateDiscountDto,
          );

          if (response.isSuccess) {
            _showSnackbar('Discount updated successfully', isSuccess: true);
            if (!mounted) return;
            Navigator.pop(context, true);
          } else {
            // ignore: dead_null_aware_expression
            _showSnackbar(response.message ?? 'Failed to update discount',
                isSuccess: false);
          }
        } else {
          final createDiscountDto = CreateDiscountDto(
            name: _nameController.text,
            percentage: double.parse(_percentageController.text),
            startDate: _startDate,
            endDate: _endDate,
            menus: _selectedMenus.map((i) => i.id).toList(),
          );

          final response =
              await discountService.createDiscount(createDiscountDto);

          if (response.isSuccess) {
            _showSnackbar('Discount added successfully', isSuccess: true);
            if (!mounted) return;
            Navigator.pop(context, true);
          } else {
            // ignore: dead_null_aware_expression
            _showSnackbar(response.message ?? 'Failed to add discount',
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
    _percentageController.dispose();
    super.dispose();
  }
}
