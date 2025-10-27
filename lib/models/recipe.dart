class Recipe {
  final String id;
  final String name;
  final String description;
  final String imageAsset; 
  final String category;
  final int prepTime;
  final int cookTime;
  final String difficulty;
  final List<String> ingredients;
  final List<String> instructions;
  final List<String> dietaryTags;
  final double calories;
  final double rating;
  bool isFavorite;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.imageAsset,
    required this.category,
    required this.prepTime,
    required this.cookTime,
    required this.difficulty,
    required this.ingredients,
    required this.instructions,
    required this.dietaryTags,
    required this.calories,
    this.rating = 4.5,
    this.isFavorite = false,
  });

  String get totalTime => '${prepTime + cookTime} min';
  String get prepTimeFormatted => '$prepTime min prep';
  String get cookTimeFormatted => '$cookTime min cook';

  bool get isVegetarian => dietaryTags.contains('vegetarian');
  bool get isVegan => dietaryTags.contains('vegan');
  bool get isGlutenFree => dietaryTags.contains('gluten-free');
}