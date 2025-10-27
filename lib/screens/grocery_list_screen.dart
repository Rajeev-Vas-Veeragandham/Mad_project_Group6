import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/meal_plan.dart';
import '../data/recipe_data.dart';
import '../data/storage.dart';

class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({Key? key}) : super(key: key);

  @override
  _GroceryListScreenState createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  MealPlan? _currentMealPlan;
  Map<String, dynamic> _groceryList = {};
  final Map<String, bool> _checkedItems = {};

  @override
  void initState() {
    super.initState();
    _loadMealPlan();
  }

  Future<void> _loadMealPlan() async {
    final plan = await Storage.loadMealPlan();
    if (plan != null) {
      setState(() {
        _currentMealPlan = plan;
        _groceryList = _generateGroceryList(plan);
        // Initialize checked items
        final ingredients = _groceryList['ingredients'] as Map<String, dynamic>;
        for (final item in ingredients.keys) {
          _checkedItems[item] = false;
        }
      });
    }
  }

  Map<String, dynamic> _generateGroceryList(MealPlan plan) {
    final ingredients = <String, Map<String, dynamic>>{};
    
    for (final slot in plan.slots) {
      if (slot.recipeId != null && !slot.isCompleted) {
        final recipe = RecipeData.recipes.firstWhere(
          (r) => r.id == slot.recipeId,
          orElse: () => RecipeData.recipes.first,
        );
        
        for (final ingredient in recipe.ingredients) {
          final parsed = _parseIngredient(ingredient);
          final itemName = parsed['name']!;
          final quantity = parsed['quantity']!;
          final unit = parsed['unit']!;
          
          if (ingredients.containsKey(itemName)) {
            final existing = ingredients[itemName]!;
            ingredients[itemName] = {
              'quantity': '${existing['quantity']} + $quantity',
              'unit': unit,
              'recipes': [...existing['recipes'], recipe.name],
            };
          } else {
            ingredients[itemName] = {
              'quantity': quantity,
              'unit': unit,
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

  Map<String, String> _parseIngredient(String ingredient) {
    // Simple parsing - extract quantity and name
    final parts = ingredient.split(' ');
    if (parts.length > 1) {
      final quantity = parts[0];
      final unit = parts[1];
      final name = parts.length > 2 ? parts.sublist(2).join(' ') : ingredient;
      return {
        'quantity': quantity,
        'unit': unit,
        'name': name,
      };
    }
    return {
      'quantity': '1',
      'unit': 'item',
      'name': ingredient,
    };
  }

  void _toggleItem(String item) {
    setState(() {
      _checkedItems[item] = !(_checkedItems[item] ?? false);
    });
  }

  void _clearCheckedItems() {
    setState(() {
      for (final item in _checkedItems.keys) {
        _checkedItems[item] = false;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All items unchecked!'),
        backgroundColor: Color(0xFF2E8B57),
      ),
    );
  }

  Future<void> _shareGroceryList() async {
    final ingredients = _groceryList['ingredients'] as Map<String, dynamic>;
    final buffer = StringBuffer();
    
    buffer.writeln('🛒 My Grocery List\n');
    buffer.writeln('Generated on: ${DateTime.now().toString().split(' ')[0]}\n');
    
    for (final item in ingredients.keys) {
      final details = ingredients[item] as Map<String, dynamic>;
      final isChecked = _checkedItems[item] ?? false;
      buffer.writeln('${isChecked ? '✅' : '☐'} ${details['quantity']} ${details['unit']} $item');
    }
    
    buffer.writeln('\n---');
    buffer.writeln('Total items: ${ingredients.length}');
    
    await Share.share(buffer.toString());
  }

  Widget _buildGroceryItem(String item, Map<String, dynamic> details, int index) {
    final isChecked = _checkedItems[item] ?? false;
    final recipeCount = (details['recipes'] as List).length;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: isChecked ? 1 : 3,
        color: isChecked ? Colors.grey[50] : Colors.white,
        child: ListTile(
          leading: Checkbox(
            value: isChecked,
            onChanged: (value) => _toggleItem(item),
            activeColor: const Color(0xFF2E8B57),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          title: Text(
            item,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              decoration: isChecked ? TextDecoration.lineThrough : TextDecoration.none,
              color: isChecked ? Colors.grey : const Color(0xFF2D3748),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${details['quantity']} ${details['unit']}',
                style: TextStyle(
                  color: isChecked ? Colors.grey : const Color(0xFF718096),
                  decoration: isChecked ? TextDecoration.lineThrough : TextDecoration.none,
                ),
              ),
              if (recipeCount > 0) ...[
                const SizedBox(height: 4),
                Wrap(
                  children: [
                    Chip(
                      label: Text(
                        '$recipeCount recipe${recipeCount > 1 ? 's' : ''}',
                        style: const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: const Color(0xFFFF6B6B),
                    ),
                  ],
                ),
              ],
            ],
          ),
          trailing: Icon(
            isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isChecked ? const Color(0xFF2E8B57) : Colors.grey[400],
          ),
          onTap: () => _toggleItem(item),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentMealPlan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Grocery List')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
              SizedBox(height: 20),
              Text(
                'No Meal Plan Found',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Create a meal plan first to generate your grocery list',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final ingredients = _groceryList['ingredients'] as Map<String, dynamic>;
    final checkedCount = _checkedItems.values.where((checked) => checked).length;
    final totalItems = ingredients.length;
    final progress = totalItems > 0 ? checkedCount / totalItems : 0.0; // FIXED: Added .0 to make it double

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery List'),
        actions: [
          if (checkedCount > 0)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearCheckedItems,
              tooltip: 'Uncheck All Items',
            ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareGroceryList,
            tooltip: 'Share Grocery List',
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Header
          Container(
            padding: const EdgeInsets.all(20),
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
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Shopping List',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$checkedCount of $totalItems items collected',
                            style: const TextStyle(color: Color(0xFF718096)),
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            value: progress.toDouble(), // FIXED: Explicitly cast to double
                            strokeWidth: 6,
                            backgroundColor: Colors.grey[300],
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E8B57)),
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E8B57),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: progress.toDouble(), // FIXED: Explicitly cast to double
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E8B57)),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          ),
          // Grocery List
          Expanded(
            child: ingredients.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.grey),
                        SizedBox(height: 20),
                        Text(
                          'No Ingredients to Shop For',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            'Add some recipes to your meal plan to generate a grocery list',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: ingredients.length,
                    itemBuilder: (context, index) {
                      final item = ingredients.keys.elementAt(index);
                      final details = ingredients[item] as Map<String, dynamic>;
                      return _buildGroceryItem(item, details, index);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: ingredients.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _shareGroceryList,
              icon: const Icon(Icons.share),
              label: const Text('Share List'),
              backgroundColor: const Color(0xFF2E8B57),
            )
          : null,
    );
  }
}