import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../models/meal_plan.dart';
import '../data/recipe_data.dart';
import '../data/storage.dart';
import 'grocery_list_screen.dart';
import 'details_screen.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({Key? key}) : super(key: key);

  @override
  _MealPlannerScreenState createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner'];
  
  late MealPlan _mealPlan;
  final Map<String, Recipe?> _selectedRecipes = {};

  @override
  void initState() {
    super.initState();
    _initializeMealPlan();
  }

  void _initializeMealPlan() {
    final slots = <MealSlot>[];
    for (final day in _days) {
      for (final mealType in _mealTypes) {
        slots.add(MealSlot(day: day, mealType: mealType));
      }
    }
    _mealPlan = MealPlan(slots: slots, weekStartDate: DateTime.now());
    _loadSavedPlan();
  }

  Future<void> _loadSavedPlan() async {
    final savedPlan = await Storage.loadMealPlan();
    if (savedPlan != null) {
      setState(() {
        _mealPlan = savedPlan;
        for (final slot in _mealPlan.slots) {
          if (slot.recipeId != null) {
            final recipe = RecipeData.recipes.firstWhere(
              (r) => r.id == slot.recipeId,
              orElse: () => RecipeData.recipes.first,
            );
            _selectedRecipes['${slot.day}_${slot.mealType}'] = recipe;
          }
        }
      });
    }
  }

  Future<void> _selectRecipe(String day, String mealType) async {
    final selectedRecipe = await showModalBottomSheet<Recipe>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 16, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Select $mealType for $day',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: RecipeData.recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = RecipeData.recipes[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: const Color(0xFF2E8B57).withOpacity(0.1),
                            ),
                            child: Icon(
                              _getMealIcon(mealType),
                              color: const Color(0xFF2E8B57),
                              size: 24,
                            ),
                          ),
                          title: Text(
                            recipe.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                recipe.description,
                                style: const TextStyle(fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2E8B57).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      recipe.totalTime,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF2E8B57),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF6B6B).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      recipe.difficulty,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFFFF6B6B),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E8B57).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add, color: Color(0xFF2E8B57), size: 20),
                          ),
                          onTap: () => Navigator.pop(context, recipe),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selectedRecipe != null) {
      setState(() {
        _selectedRecipes['${day}_${mealType}'] = selectedRecipe;
        
        final slotIndex = _mealPlan.slots.indexWhere(
          (slot) => slot.day == day && slot.mealType == mealType,
        );
        if (slotIndex != -1) {
          _mealPlan.slots[slotIndex] = MealSlot(
            day: day,
            mealType: mealType,
            recipeId: selectedRecipe.id,
            isCompleted: false,
          );
        }
      });
      await Storage.saveMealPlan(_mealPlan);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: '✅ Added ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: selectedRecipe.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: ' to $day $mealType',
                ),
              ],
            ),
          ),
          backgroundColor: const Color(0xFF2E8B57),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType) {
      case 'Breakfast':
        return Icons.breakfast_dining;
      case 'Lunch':
        return Icons.lunch_dining;
      case 'Dinner':
        return Icons.dinner_dining;
      default:
        return Icons.restaurant;
    }
  }

  Color _getMealColor(String mealType) {
    switch (mealType) {
      case 'Breakfast':
        return const Color(0xFFFFD166); // Yellow
      case 'Lunch':
        return const Color(0xFF2E8B57); // Green
      case 'Dinner':
        return const Color(0xFFFF6B6B); // Red
      default:
        return const Color(0xFF2E8B57);
    }
  }

  void _clearMealPlan() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Meal Plan'),
        content: const Text('Are you sure you want to clear your entire meal plan? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedRecipes.clear();
                _initializeMealPlan();
              });
              Storage.saveMealPlan(_mealPlan);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Meal plan cleared!'),
                  backgroundColor: Color(0xFF2E8B57),
                ),
              );
            },
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealSlot(String day, String mealType) {
  final recipe = _selectedRecipes['${day}_${mealType}'];
  final mealColor = _getMealColor(mealType);
  
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 4),
    child: Card(
      elevation: recipe != null ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: recipe != null ? mealColor.withOpacity(0.15) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal Type Header
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: recipe != null ? mealColor.withOpacity(0.2) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: recipe != null ? mealColor : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    _getMealIcon(mealType),
                    color: recipe != null ? mealColor : Colors.grey[400],
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    mealType,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: recipe != null ? const Color(0xFF2D3748) : Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
                if (recipe != null)
                  IconButton(
                    icon: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.clear, size: 16, color: Colors.red),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedRecipes.remove('${day}_${mealType}');
                        final slotIndex = _mealPlan.slots.indexWhere(
                          (s) => s.day == day && s.mealType == mealType,
                        );
                        if (slotIndex != -1) {
                          _mealPlan.slots[slotIndex] = MealSlot(
                            day: day,
                            mealType: mealType,
                          );
                        }
                      });
                      Storage.saveMealPlan(_mealPlan);
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )
                else
                  IconButton(
                    icon: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E8B57).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Color(0xFF2E8B57), size: 16),
                    ),
                    onPressed: () => _selectRecipe(day, mealType),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            
            // Recipe Content
            if (recipe != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // FIXED: Wrap the time/difficulty row to prevent overflow
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.schedule, size: 10, color: Colors.grey[600]),
                            const SizedBox(width: 2),
                            Text(
                              recipe.totalTime,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bolt, size: 10, color: Colors.grey[600]),
                            const SizedBox(width: 2),
                            Text(
                              recipe.difficulty,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectRecipe(day, mealType),
                child: Container(
                  height: 40,
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min, // ADDED THIS
                    children: [
                      Icon(Icons.add, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Flexible( // CHANGED: Wrap text in Flexible
                        child: Text(
                          'Add Recipe',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis, // ADDED: Handle overflow
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

  Widget _buildDayColumn(String day) {
    final dayRecipes = _selectedRecipes.entries
        .where((entry) => entry.key.startsWith(day))
        .length;
    
    return SizedBox(
      width: 160, // Fixed width for consistent columns
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Day Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E8B57).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      day,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: dayRecipes > 0 ? const Color(0xFF2E8B57) : Colors.grey[300],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$dayRecipes/3',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: dayRecipes > 0 ? Colors.white : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Meal Slots
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: _mealTypes
                      .map((mealType) => _buildMealSlot(day, mealType))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plannedMeals = _selectedRecipes.length;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Planner'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2D3748),
        elevation: 0,
        actions: [
          if (plannedMeals > 0) ...[
            IconButton(
              icon: const Icon(Icons.shopping_cart, size: 20),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GroceryListScreen()),
                );
              },
              tooltip: 'Generate Grocery List',
            ),
            IconButton(
              icon: const Icon(Icons.clear_all, size: 20),
              onPressed: _clearMealPlan,
              tooltip: 'Clear Meal Plan',
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Week Overview Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2E8B57).withOpacity(0.1),
                  const Color(0xFFFF6B6B).withOpacity(0.1),
                ],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Weekly Meal Plan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plannedMeals > 0 
                            ? 'You have $plannedMeals meals planned'
                            : 'Plan your meals for the week',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (plannedMeals > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E8B57),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$plannedMeals meals',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Days Grid - Horizontal Scroll
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _days.map(_buildDayColumn).toList(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: plannedMeals > 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GroceryListScreen()),
                );
              },
              icon: const Icon(Icons.shopping_basket, size: 20),
              label: const Text(
                'Grocery List',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              backgroundColor: const Color(0xFF2E8B57),
              elevation: 4,
            )
          : FloatingActionButton.extended(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tap on any meal slot to start planning!'),
                    backgroundColor: Color(0xFF2E8B57),
                  ),
                );
              },
              icon: const Icon(Icons.tips_and_updates, size: 20),
              label: const Text(
                'Start Planning',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              backgroundColor: const Color(0xFF2E8B57),
              elevation: 4,
            ),
    );
  }
}