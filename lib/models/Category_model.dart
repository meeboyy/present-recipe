class Category {
  String id;
  String title;
  String imageUrl;
  int recipeCount;

  Category(
      {required this.id,
      required this.title,
      required this.imageUrl,
      required this.recipeCount});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
        id: json['idCategory'],
        title: json['strCategory'],
        imageUrl: json['strCategoryThumb'],
        recipeCount: 0);
  }
}
