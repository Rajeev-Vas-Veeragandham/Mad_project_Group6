import 'recipe.dart'; // ADD THIS IMPORT

class MealSlot {
  final String day; // e.g., Monday
  final String mealType; // Breakfast/Lunch/Dinner/Snack
  String? recipeId; // id of assigned recipe
  bool isCompleted;

  MealSlot({
    required this.day,
    required this.mealType,
    this.recipeId,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'day': day,
        'mealType': mealType,
        'recipeId': recipeId,
        'isCompleted': isCompleted,
      };

  factory MealSlot.fromJson(Map<String, dynamic> j) => MealSlot(
        day: j['day'],
        mealType: j['mealType'],
        recipeId: j['recipeId'],
        isCompleted: j['isCompleted'] ?? false,
      );
}

class MealPlan {
  final List<MealSlot> slots;
  final DateTime weekStartDate;

  MealPlan({required this.slots, required this.weekStartDate});

  Map<String, dynamic> toJson() => {
        'slots': slots.map((s) => s.toJson()).toList(),
        'weekStartDate': weekStartDate.toIso8601String(),
      };

  factory MealPlan.fromJson(Map<String, dynamic> j) => MealPlan(
        slots: (j['slots'] as List)
            .map((e) => MealSlot.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        weekStartDate: DateTime.parse(j['weekStartDate']),
      );

  // Generate grocery list from meal plan
  Map<String, dynamic> generateGroceryList(List<Recipe> allRecipes) {
    final ingredients = <String, Map<String, dynamic>>{};
    
    for (final slot in slots) {
      if (slot.recipeId != null && !slot.isCompleted) {
        final recipe = allRecipes.firstWhere(
          (r) => r.id == slot.recipeId,
          orElse: () => Recipe(
            id: '',
            name: '',
            description: '',
            imageAsset: '',
            category: '',
            prepTime: 0,
            cookTime: 0,
            difficulty: '',
            ingredients: [],
            instructions: [],
            dietaryTags: [],
            calories: 0,
          ),
        );
        
        for (final ingredient in recipe.ingredients) {
          final quantity = _parseQuantity(ingredient);
          final itemName = _parseItemName(ingredient);
          
          if (ingredients.containsKey(itemName)) {
            final existing = ingredients[itemName]!;
            ingredients[itemName] = {
              'quantity': '${existing['quantity']} + ${quantity['quantity']}',
              'unit': quantity['unit'],
              'recipes': [...existing['recipes'], recipe.name],
            };
          } else {
            ingredients[itemName] = {
              'quantity': quantity['quantity'],
              'unit': quantity['unit'],
              'recipes': [recipe.name],
            };
          }
        }
      }
    }
    
    return {
      'ingredients': ingredients,
      'totalItems': ingredients.length,
      'generatedDate': DateTime.now(),
    };
  }
  
  Map<String, String> _parseQuantity(String ingredient) {
    // Simple parsing - in real app, use more sophisticated parsing
    final parts = ingredient.split(' ');
    if (parts.length > 1) {
      return {
        'quantity': parts[0],
        'unit': parts[1],
      };
    }
    return {'quantity': '1', 'unit': 'item'};
  }
  
  String _parseItemName(String ingredient) {
    final parts = ingredient.split(' ');
    return parts.length > 2 ? parts.sublist(2).join(' ') : ingredient;
  }
}