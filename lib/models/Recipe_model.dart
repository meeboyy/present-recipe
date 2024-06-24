class Recipe {
  final String id;
  final String title;
  final String imageUrl;
  final String category;
  final double
      rating; // Assume rating is provided by API, otherwise, you can default it
  final int cookingTime; // Assume cooking time in minutes
  final String
      difficulty; // Assume difficulty is a string like "Easy", "Medium", "Hard"

  Recipe({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.category,
    required this.rating,
    required this.cookingTime,
    required this.difficulty,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['idMeal'],
      title: json['strMeal'],
      imageUrl: json['strMealThumb'],
      category: json.containsKey('strCategory')
          ? json['strCategory'].toString()
          : "none",
      rating: json.containsKey('rating')
          ? json['rating'].toDouble()
          : 4.0, // Default rating if not provided
      cookingTime: json.containsKey('cookingTime')
          ? json['cookingTime']
          : 30, // Default cooking time if not provided
      difficulty: json.containsKey('difficulty')
          ? json['difficulty']
          : 'Medium', // Default difficulty if not provided
    );
  }
}
