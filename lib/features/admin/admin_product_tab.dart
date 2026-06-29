// Purpose: Redesigned admin product CRUD tab with list, detail, and sheet-based forms.
// Main callers: AdminHomePage IndexedStack.
// Key dependencies: AdminProvider, ProductModel, theme tokens, currency/snackbar helpers, admin UI components.
// Main/public functions: AdminProductTab.
// Side effects: Opens detail/form sheets; fetches and mutates products through AdminProvider HTTP calls.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/helpers/currency_helper.dart';
import '../../core/helpers/snackbar_helper.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/product_model.dart';
import '../../providers/admin_provider.dart';
import 'widgets/admin_components.dart';
import 'widgets/admin_form_sheet.dart';

class AdminProductTab extends StatelessWidget {
  const AdminProductTab({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    return RefreshIndicator(
      onRefresh: admin.fetchProducts,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          AdminPageHeader(
            title: 'Kelola Produk',
            subtitle: 'Tambah, edit, dan nonaktifkan produk katalog.',
            action: AdminActionButton(
              label: 'Tambah Produk',
              icon: Icons.add,
              onPressed: admin.isSaving
                  ? null
                  : () => _openForm(context, admin: admin),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (admin.isLoading && admin.products.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (admin.products.isEmpty)
            const AdminEmptyState(message: 'Belum ada produk.')
          else
            ...admin.products.map(
              (product) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _ProductTile(
                  product: product,
                  onTap: () =>
                      _openDetail(context, admin: admin, product: product),
                  onEdit: () =>
                      _openForm(context, admin: admin, product: product),
                  onDelete: () => _deleteProduct(context, product),
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
    ProductModel? product,
  }) {
    showAdminFormSheet(
      context: context,
      child: _ProductForm(admin: admin, product: product),
    );
  }

  void _openDetail(
    BuildContext context, {
    required AdminProvider admin,
    required ProductModel product,
  }) {
    showAdminFormSheet(
      context: context,
      child: _ProductDetailSheet(
        product: product,
        onEdit: () {
          Navigator.of(context).pop();
          _openForm(context, admin: admin, product: product);
        },
      ),
    );
  }

  Future<void> _deleteProduct(
    BuildContext context,
    ProductModel product,
  ) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hapus produk?'),
            content: Text('${product.name} akan dinonaktifkan.'),
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
    final success = await admin.deleteProduct(product.id);
    if (!context.mounted) {
      return;
    }
    if (success) {
      showSuccessSnackBar(context, 'Produk dihapus.');
    } else {
      showErrorSnackBar(
        context,
        admin.errorMessage ?? 'Gagal menghapus produk.',
      );
    }
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.product,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    return AdminSurface(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProductImage(product: product, size: 64),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: AppTextStyles.bodyStrong.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  formatRupiah(product.price),
                  style: AppTextStyles.tagline.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Stok ${product.stock} - ${product.categoryName.isEmpty ? 'Tanpa kategori' : product.categoryName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          AdminIconAction(
            tooltip: 'Edit',
            onPressed: admin.isSaving ? null : onEdit,
            icon: Icons.edit_outlined,
          ),
          const SizedBox(width: AppSpacing.xs),
          AdminIconAction(
            tooltip: 'Hapus',
            onPressed: admin.isSaving ? null : onDelete,
            icon: Icons.delete_outline,
          ),
        ],
      ),
    );
  }
}

class _ProductDetailSheet extends StatelessWidget {
  const _ProductDetailSheet({required this.product, required this.onEdit});

  final ProductModel product;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final category = product.categoryName.isEmpty
        ? 'Tanpa kategori'
        : product.categoryName;
    final description = product.description.trim().isEmpty
        ? 'Belum ada deskripsi.'
        : product.description.trim();
    final imageUrl = product.imageUrl.trim().isEmpty
        ? 'Tidak ada gambar.'
        : product.imageUrl.trim();
    return AdminFormSheet(
      title: 'Detail Produk',
      children: [
        AspectRatio(
          aspectRatio: 16 / 10,
          child: _ProductImage(product: product, size: double.infinity),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          product.name,
          style: AppTextStyles.tagline.copyWith(color: context.color.ink),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          description,
          style: AppTextStyles.caption.copyWith(
            color: context.color.inkMuted80,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AdminSurface(
          padding: const EdgeInsets.all(AppSpacing.md),
          tint: context.color.canvasParchment,
          child: Column(
            children: [
              _ProductInfoRow(
                label: 'Harga',
                value: formatRupiah(product.price),
              ),
              _ProductInfoRow(label: 'Stok', value: '${product.stock}'),
              _ProductInfoRow(label: 'Kategori', value: category),
              _ProductInfoRow(
                label: 'Status',
                value: product.isActive ? 'Aktif' : 'Nonaktif',
              ),
              _ProductInfoRow(label: 'Gambar', value: imageUrl),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AdminActionButton(
          label: 'Edit Produk',
          icon: Icons.edit_outlined,
          onPressed: onEdit,
        ),
      ],
    );
  }
}

class _ProductInfoRow extends StatelessWidget {
  const _ProductInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 78,
            child: Text(label, style: AppTextStyles.finePrint),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.captionStrong.copyWith(
                color: context.color.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.product, required this.size});

  final ProductModel product;
  final double size;

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.imageUrl.trim();
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        width: size,
        height: size,
        color: context.color.canvasParchment,
        child: imageUrl.isEmpty
            ? _ProductImageFallback(product: product)
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    _ProductImageFallback(product: product),
              ),
      ),
    );
  }
}

class _ProductImageFallback extends StatelessWidget {
  const _ProductImageFallback({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.primary.withValues(alpha: 0.08),
      child: Center(
        child: Icon(
          Icons.inventory_2_outlined,
          color: context.color.primary,
          size: product.imageUrl.isEmpty ? 24 : 30,
        ),
      ),
    );
  }
}

class _ProductForm extends StatefulWidget {
  const _ProductForm({required this.admin, this.product});

  final AdminProvider admin;
  final ProductModel? product;

  @override
  State<_ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<_ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _imageController;
  String? _categoryId;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name ?? '');
    _descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    _priceController = TextEditingController(
      text: product == null ? '' : formatRupiah(product.price),
    );
    _stockController = TextEditingController(
      text: product == null ? '' : '${product.stock}',
    );
    _imageController = TextEditingController(text: product?.imageUrl ?? '');
    _categoryId = product?.categoryId.isEmpty == true
        ? null
        : product?.categoryId;
    _isActive = product?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final product = widget.product == null
        ? await widget.admin.createProduct(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            price: _parsePrice(_priceController.text),
            stock: int.parse(_stockController.text.trim()),
            categoryId: _categoryId!,
            imageUrl: _imageController.text.trim(),
          )
        : await widget.admin.updateProduct(
            id: widget.product!.id,
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            price: _parsePrice(_priceController.text),
            stock: int.parse(_stockController.text.trim()),
            categoryId: _categoryId!,
            imageUrl: _imageController.text.trim(),
            isActive: _isActive,
          );
    if (!mounted) {
      return;
    }
    if (product == null) {
      showErrorSnackBar(
        context,
        widget.admin.errorMessage ?? 'Gagal menyimpan produk.',
      );
      return;
    }
    Navigator.of(context).pop();
    showSuccessSnackBar(context, 'Produk ${product.name} disimpan.');
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory =
        widget.admin.categories.any((category) => category.id == _categoryId)
        ? _categoryId
        : null;
    return AdminFormSheet(
      title: widget.product == null ? 'Tambah Produk' : 'Edit Produk',
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'Nama produk wajib diisi.'
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                minLines: 2,
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
                inputFormatters: const [_RupiahInputFormatter()],
                validator: _validatePositiveNumber,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number,
                validator: _validateStock,
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: widget.admin.categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _categoryId = value),
                validator: (value) =>
                    value == null ? 'Kategori wajib dipilih.' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              if (widget.product != null) ...[
                const SizedBox(height: AppSpacing.sm),
                AdminSurface(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Produk aktif',
                          style: AppTextStyles.captionStrong.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Switch(
                        value: _isActive,
                        onChanged: (value) => setState(() => _isActive = value),
                      ),
                    ],
                  ),
                ),
              ],
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

  String? _validatePositiveNumber(String? value) {
    final parsed = _tryParsePrice(value ?? '');
    if (parsed == null || parsed <= 0) {
      return 'Harga wajib lebih dari 0.';
    }
    return null;
  }

  String? _validateStock(String? value) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed < 0) {
      return 'Stok wajib 0 atau lebih.';
    }
    return null;
  }
}

num _parsePrice(String value) => _tryParsePrice(value) ?? 0;

num? _tryParsePrice(String value) {
  final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) {
    return null;
  }
  return num.tryParse(digits);
}

class _RupiahInputFormatter extends TextInputFormatter {
  const _RupiahInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final parsed = _tryParsePrice(newValue.text);
    if (parsed == null) {
      return TextEditingValue.empty;
    }
    final text = formatRupiah(parsed);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
