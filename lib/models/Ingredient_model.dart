class Ingredient {
  int id;
  String title;
  String desc;

  Ingredient({
    required this.id,
    required this.title,
    required this.desc,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: int.parse(json['idIngredient']),
      title: json['strIngredient'],
      desc: json['strDescription'] ?? '',
    );
  }
}
