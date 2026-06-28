// Purpose: Category data model for product filter UI.
// Main callers: ProductProvider, HomePage.
// Key dependencies: None.
// Main/public functions: CategoryModel, CategoryModel.fromJson.
// Side effects: None.

class CategoryModel {
  const CategoryModel({required this.id, required this.name});

  final String id;
  final String name;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? ''}',
    );
  }
}
