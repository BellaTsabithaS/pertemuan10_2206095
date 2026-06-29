// Purpose: Redesigned admin category CRUD tab with sheet-based forms.
// Main callers: AdminHomePage IndexedStack.
// Key dependencies: AdminProvider, CategoryModel, snackbar helper, admin UI components.
// Main/public functions: AdminCategoryTab.
// Side effects: Fetches and mutates categories through AdminProvider.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/helpers/snackbar_helper.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/category_model.dart';
import '../../providers/admin_provider.dart';
import 'widgets/admin_components.dart';
import 'widgets/admin_form_sheet.dart';

class AdminCategoryTab extends StatelessWidget {
  const AdminCategoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    return RefreshIndicator(
      onRefresh: admin.fetchCategories,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          AdminPageHeader(
            title: 'Kelola Kategori',
            subtitle: 'Atur struktur kategori katalog.',
            action: AdminActionButton(
              label: 'Tambah',
              icon: Icons.add,
              onPressed: admin.isSaving
                  ? null
                  : () => _openForm(context, admin: admin),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (admin.isLoading && admin.categories.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (admin.categories.isEmpty)
            const AdminEmptyState(message: 'Belum ada kategori.')
          else
            ...admin.categories.map(
              (category) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: AdminSurface(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          category.name,
                          style: AppTextStyles.bodyStrong.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      AdminIconAction(
                        tooltip: 'Edit',
                        onPressed: admin.isSaving
                            ? null
                            : () => _openForm(
                                context,
                                admin: admin,
                                category: category,
                              ),
                        icon: Icons.edit_outlined,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      AdminIconAction(
                        tooltip: 'Hapus',
                        onPressed: admin.isSaving
                            ? null
                            : () => _deleteCategory(context, category.id),
                        icon: Icons.delete_outline,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openForm(
    BuildContext context, {
    required AdminProvider admin,
    CategoryModel? category,
  }) {
    showAdminFormSheet(
      context: context,
      child: _CategoryForm(admin: admin, category: category),
    );
  }

  Future<void> _deleteCategory(BuildContext context, String id) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hapus kategori?'),
            content: const Text(
              'Kategori akan dihapus jika tidak dipakai produk.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Hapus'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !context.mounted) {
      return;
    }
    final admin = context.read<AdminProvider>();
    final success = await admin.deleteCategory(id);
    if (!context.mounted) {
      return;
    }
    if (success) {
      showSuccessSnackBar(context, 'Kategori dihapus.');
    } else {
      showErrorSnackBar(
        context,
        admin.errorMessage ?? 'Gagal menghapus kategori.',
      );
    }
  }
}

class _CategoryForm extends StatefulWidget {
  const _CategoryForm({required this.admin, this.category});

  final AdminProvider admin;
  final CategoryModel? category;

  @override
  State<_CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<_CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  final _descriptionController = TextEditingController();
  final _imageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final category = widget.category == null
        ? await widget.admin.createCategory(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            imageUrl: _imageController.text.trim(),
          )
        : await widget.admin.updateCategory(
            id: widget.category!.id,
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            imageUrl: _imageController.text.trim(),
          );
    if (!mounted) {
      return;
    }
    if (category == null) {
      showErrorSnackBar(
        context,
        widget.admin.errorMessage ?? 'Gagal menyimpan kategori.',
      );
      return;
    }
    Navigator.of(context).pop();
    showSuccessSnackBar(context, 'Kategori ${category.name} disimpan.');
  }

  @override
  Widget build(BuildContext context) {
    return AdminFormSheet(
      title: widget.category == null ? 'Tambah Kategori' : 'Edit Kategori',
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Kategori'),
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'Nama kategori wajib diisi.'
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: widget.admin.isSaving ? null : _submit,
                child: Text(widget.admin.isSaving ? 'Menyimpan...' : 'Simpan'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
