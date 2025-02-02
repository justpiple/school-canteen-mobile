import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../services/menu_service.dart';
import '../../models/menu.dart';
import 'menu_form_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ManageMenuPage extends StatefulWidget {
  const ManageMenuPage({super.key});

  @override
  State<ManageMenuPage> createState() => _ManageMenuPageState();
}

class _ManageMenuPageState extends State<ManageMenuPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Menu'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            tooltip: "Add menu",
            onPressed: _showAddMenuDialog,
          ),
        ],
      ),
      body: Consumer<MenuService>(
        builder: (context, menuService, child) {
          return FutureBuilder(
            future: menuService.getMenus(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final menus = snapshot.data?.data ?? [];
              return menus.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _refreshMenus,
                      child: _buildResponsiveMenuList(menus),
                    );
            },
          );
        },
      ),
    );
  }

  Widget _buildResponsiveMenuList(List<Menu> menus) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth =
            constraints.maxWidth > 600 ? 600 : constraints.maxWidth;

        return Center(
          child: SizedBox(
            width: maxWidth,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: menus.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildMenuCard(menus[index]),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _refreshMenus() async {
    final menuService = Provider.of<MenuService>(context, listen: false);
    await menuService.getMenus(forceRefresh: true);
    setState(() {}); // Memaksa rebuild untuk menampilkan data terbaru
  }

  Widget _buildMenuCard(Menu menu) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => _showEditMenuDialog(menu),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: LucideIcons.edit,
            label: 'Edit',
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(12)),
          ),
          SlidableAction(
            onPressed: (context) => _deleteMenu(menu),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: LucideIcons.trash2,
            label: 'Delete',
            borderRadius:
                const BorderRadius.horizontal(right: Radius.circular(12)),
          ),
        ],
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () => _showEditMenuDialog(menu),
          child: SizedBox(
            height: 120,
            child: Row(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      menu.photo.isNotEmpty
                          ? Image.network(
                              menu.photo,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildPlaceholderImage(),
                            )
                          : _buildPlaceholderImage(),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: menu.type == 'FOOD'
                                ? Colors.deepOrange.withValues(alpha: 0.7)
                                : Colors.lightBlue.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            menu.type,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          menu.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Text(
                            menu.description ?? 'No description',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          'Rp ${NumberFormat('#,###').format(menu.price)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _deleteMenu(Menu menu) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete Menu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${menu.name}"?'),
            const SizedBox(height: 8),
            Text(
              'This action cannot be undone.',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        if (!mounted) return;
        final menuService = Provider.of<MenuService>(context, listen: false);
        final response = await menuService.deleteMenu(menu.id);

        if (response.isSuccess) {
          _showSnackbar('Menu deleted successfully', isSuccess: true);
          setState(() {});
        } else {
          // ignore: dead_null_aware_expression
          _showSnackbar(response.message ?? 'Failed to delete menu',
              isSuccess: false);
        }
      } catch (e) {
        _showSnackbar('An error occurred while deleting the menu',
            isSuccess: false);
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.fileQuestion,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'No menus found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showAddMenuDialog,
            icon: const Icon(LucideIcons.plus),
            label: const Text('Add First Menu'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMenuDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MenuFormPage(),
      ),
    ).then((value) {
      if (value == true) {
        setState(() {});
      }
    });
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Icon(
          LucideIcons.image,
          size: 48,
          color: Colors.grey[300],
        ),
      ),
    );
  }

  void _showEditMenuDialog(Menu menu) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MenuFormPage(menu: menu),
      ),
    ).then((value) {
      if (value == true) {
        setState(() {});
      }
    });
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
