import '../models/recipe.dart';

class RecipeData {
  static List<Recipe> recipes = [
    Recipe(
      id: '1',
      name: '🍝 Spaghetti Carbonara',
      description: 'Creamy Italian pasta with pancetta and parmesan',
      imageAsset: 'assets/images/carbonara.jpg', // Changed to imageAsset
      category: 'Pasta',
      prepTime: 15,
      cookTime: 20,
      difficulty: 'Medium',
      dietaryTags: ['Meat'], // Contains meat
      calories: 450,
      ingredients: [
        '200g spaghetti',
        '100g guanciale or pancetta, diced',
        '2 large eggs',
        '50g Pecorino Romano cheese, grated',
        '50g Parmigiano Reggiano, grated',
        'Freshly ground black pepper',
        'Salt',
      ],
      instructions: [
        'Bring a large pot of salted water to boil and cook spaghetti al dente',
        'While pasta cooks, fry pancetta until crispy in a large pan',
        'Whisk eggs with grated cheeses and black pepper',
        'Reserve 1 cup pasta water before draining',
        'Combine hot pasta with pancetta and its fat',
        'Remove from heat, quickly stir in egg mixture',
        'Add pasta water gradually until creamy consistency',
        'Serve immediately with extra cheese and pepper',
      ],
    ),
    Recipe(
      id: '2',
      name: '🥗 Quinoa Buddha Bowl',
      description: 'Nutritious plant-based bowl with fresh vegetables',
      imageAsset: 'assets/images/buddha_bowl.jpg', // Changed to imageAsset
      category: 'Healthy',
      prepTime: 15,
      cookTime: 20,
      difficulty: 'Easy',
      dietaryTags: ['vegetarian', 'vegan', 'gluten-free'],
      calories: 380,
      ingredients: [
        '1 cup quinoa',
        '1 avocado, sliced',
        '1 cup chickpeas',
        '1 cup mixed vegetables',
        '2 tbsp tahini',
        '1 lemon, juiced',
        '1 tbsp olive oil',
        'Salt and pepper to taste',
      ],
      instructions: [
        'Cook quinoa according to package instructions',
        'Roast chickpeas with olive oil and spices',
        'Prepare vegetables and avocado',
        'Whisk tahini with lemon juice for dressing',
        'Assemble bowl with quinoa base',
        'Top with vegetables and chickpeas',
        'Drizzle with tahini dressing',
      ],
    ),
    Recipe(
      id: '3',
      name: '🌱 Vegan Avocado Pasta',
      description: 'Creamy avocado sauce with fresh herbs',
      imageAsset: 'assets/images/avocado_pasta.jpg', // Changed to imageAsset
      category: 'Pasta',
      prepTime: 10,
      cookTime: 15,
      difficulty: 'Easy',
      dietaryTags: ['vegetarian', 'vegan'],
      calories: 320,
      ingredients: [
        '200g whole wheat pasta',
        '2 ripe avocados',
        '2 cloves garlic',
        'Fresh basil leaves',
        '2 tbsp lemon juice',
        '3 tbsp olive oil',
        'Salt and pepper to taste',
      ],
      instructions: [
        'Cook pasta according to package instructions',
        'Blend avocados, garlic, basil, lemon juice until smooth',
        'Slowly add olive oil while blending',
        'Drain pasta and mix with avocado sauce',
        'Season with salt and pepper',
        'Garnish with fresh basil',
      ],
    ),
    Recipe(
      id: '4',
      name: '🍫 Vegan Chocolate Cake',
      description: 'Decadent gluten-free chocolate dessert',
      imageAsset: 'assets/images/vegan_cake.jpg', // Changed to imageAsset
      category: 'Dessert',
      prepTime: 20,
      cookTime: 35,
      difficulty: 'Medium',
      dietaryTags: ['vegetarian', 'vegan', 'gluten-free'],
      calories: 280,
      ingredients: [
        '200g almond flour',
        '50g cocoa powder',
        '150g maple syrup',
        '100ml coconut oil',
        '1 tsp baking soda',
        '1 tbsp apple cider vinegar',
        '1 tsp vanilla extract',
        'Pinch of salt',
      ],
      instructions: [
        'Preheat oven to 180°C (350°F)',
        'Mix dry ingredients in a bowl',
        'Combine wet ingredients separately',
        'Mix wet and dry ingredients gently',
        'Pour into lined cake tin',
        'Bake for 30-35 minutes',
        'Cool completely before serving',
      ],
    ),
    Recipe(
      id: '5',
      name: '🍗 Chicken Stir Fry',
      description: 'Colorful vegetables with tender chicken in savory sauce',
      imageAsset: 'assets/images/stir_fry.jpg', // Changed to imageAsset
      category: 'Asian',
      prepTime: 20,
      cookTime: 15,
      difficulty: 'Easy',
      dietaryTags: ['Meat'], 
      calories: 420,
      ingredients: [
        '2 chicken breasts, sliced',
        '1 red bell pepper, sliced',
        '1 yellow bell pepper, sliced',
        '1 onion, sliced',
        '2 cloves garlic, minced',
        '1 tbsp ginger, grated',
        '3 tbsp soy sauce',
        '1 tbsp oyster sauce',
        '1 tsp sesame oil',
        '2 tbsp vegetable oil',
        'Green onions for garnish',
      ],
      instructions: [
        'Slice chicken and marinate with 1 tbsp soy sauce',
        'Heat oil in wok over high heat',
        'Stir-fry chicken until golden, remove from wok',
        'Add vegetables and stir-fry until crisp-tender',
        'Return chicken to wok',
        'Add sauces and toss to combine',
        'Finish with sesame oil and garnish',
      ],
    ),
  ];

  // Filter methods
  static List<Recipe> getVegetarianRecipes() {
    return recipes.where((recipe) => recipe.isVegetarian).toList();
  }

  static List<Recipe> getVeganRecipes() {
    return recipes.where((recipe) => recipe.isVegan).toList();
  }

  static List<Recipe> getGlutenFreeRecipes() {
    return recipes.where((recipe) => recipe.isGlutenFree).toList();
  }

  static List<String> getAllCategories() {
    return recipes.map((recipe) => recipe.category).toSet().toList();
  }
}