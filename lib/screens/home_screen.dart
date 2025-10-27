import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../data/recipe_data.dart';
import '../data/storage.dart';
import 'details_screen.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Recipe> recipes = RecipeData.recipes;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final Set<String> _selectedDietaryFilters = {};

  final List<String> _categories = ['All', 'Pasta', 'Asian', 'Dessert', 'Breakfast', 'Healthy'];
  final List<String> _dietaryOptions = ['Vegetarian', 'Vegan', 'Gluten-free', 'Meat'];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _loadDietaryPreferences();
  }

  Future<void> _loadFavorites() async {
    final favs = await Storage.loadFavorites();
    setState(() {
      for (final recipe in recipes) {
        recipe.isFavorite = favs.contains(recipe.id);
      }
    });
  }

  Future<void> _toggleFavorite(Recipe recipe) async {
    final favs = await Storage.loadFavorites();
    if (recipe.isFavorite) {
      favs.remove(recipe.id);
    } else {
      favs.add(recipe.id);
    }
    await Storage.saveFavorites(favs);
    setState(() {
      recipe.isFavorite = !recipe.isFavorite;
    });
  }

  Future<void> _loadDietaryPreferences() async {
    final prefs = await Storage.loadDietaryPreferences();
    setState(() {
      _selectedDietaryFilters.addAll(prefs);
    });
  }

  Future<void> _saveDietaryPreferences() async {
    await Storage.saveDietaryPreferences(_selectedDietaryFilters);
  }

  void _shareRecipe(Recipe recipe) {
    final text = '''
${recipe.name}

${recipe.description}

⏱️ Total Time: ${recipe.totalTime}
📊 Difficulty: ${recipe.difficulty}
🔥 Calories: ${recipe.calories.toInt()}

🥗 Ingredients:
${recipe.ingredients.map((ing) => '• $ing').join('\n')}

👩‍🍳 Instructions:
${recipe.instructions.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n')}

Bon Appétit! 🍴
''';
    
    Share.share(text);
  }

  List<Recipe> get filteredRecipes {
    List<Recipe> filtered = recipes;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((recipe) {
        return recipe.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            recipe.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            recipe.category.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply category filter
    if (_selectedCategory != 'All') {
      filtered = filtered.where((recipe) => recipe.category == _selectedCategory).toList();
    }

    // Apply dietary filters
    if (_selectedDietaryFilters.isNotEmpty) {
      filtered = filtered.where((recipe) {
        if (_selectedDietaryFilters.contains('Vegetarian') && !recipe.isVegetarian) return false;
        if (_selectedDietaryFilters.contains('Vegan') && !recipe.isVegan) return false;
        if (_selectedDietaryFilters.contains('Gluten-free') && !recipe.isGlutenFree) return false;
        return true;
      }).toList();
    }

    return filtered;
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E8B57) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E8B57) : Colors.grey[300]!,
            width: isSelected ? 0 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFF2E8B57).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF718096),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildDietaryFilterChip(String dietary) {
    final isSelected = _selectedDietaryFilters.contains(dietary);
    return FilterChip(
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedDietaryFilters.add(dietary);
          } else {
            _selectedDietaryFilters.remove(dietary);
          }
          _saveDietaryPreferences();
        });
      },
      label: Text(dietary),
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF2E8B57),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF718096),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? const Color(0xFF2E8B57) : Colors.grey[300]!,
        ),
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.white,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DetailsScreen(recipe: recipe)),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section with Asset Image
                Stack(
                  children: [
                    // Asset Image
                    Container(
                      height: 160,
                      width: double.infinity,
                      child: Image.asset(
                        recipe.imageAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 160,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  const Color(0xFF2E8B57).withOpacity(0.7),
                                  const Color(0xFF2E8B57).withOpacity(0.3),
                                ],
                              ),
                            ),
                            child: Icon(
                              Icons.restaurant,
                              size: 60,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          );
                        },
                      ),
                    ),
                    // Gradient Overlay
                    Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.2),
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                    // Category Badge
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          recipe.category,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E8B57),
                          ),
                        ),
                      ),
                    ),
                    // Favorite Button
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: recipe.isFavorite ? const Color(0xFFFF6B6B) : Colors.grey[600],
                            size: 22,
                          ),
                          onPressed: () => _toggleFavorite(recipe),
                        ),
                      ),
                    ),
                    // Share Button
                    Positioned(
                      top: 12,
                      right: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.share, size: 22, color: Color(0xFF2E8B57)),
                          onPressed: () => _shareRecipe(recipe),
                        ),
                      ),
                    ),
                    // Dietary Tags
                    if (recipe.dietaryTags.isNotEmpty)
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: Wrap(
                          spacing: 6,
                          children: recipe.dietaryTags.map((tag) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2E8B57),
                              ),
                            ),
                          )).toList(),
                        ),
                      ),
                  ],
                ),
                // Content Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        recipe.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF718096),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      // Recipe Meta Info
                      Row(
                        children: [
                          _buildMetaInfo(Icons.schedule, recipe.totalTime),
                          const SizedBox(width: 16),
                          _buildMetaInfo(Icons.bolt, recipe.difficulty),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E8B57).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, color: Color(0xFFFFD166), size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  recipe.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2E8B57),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF2E8B57)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2E8B57),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecipes = this.filteredRecipes;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            title: const Text('Recipe and Meal Planning App 🍴'),
            floating: true,
            snap: true,
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          // Search Bar
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF2E8B57)),
                  hintText: 'Search recipes...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
          ),
          // Dietary Filters
          if (_selectedDietaryFilters.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    const Text(
                      'Active filters:',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2D3748)),
                    ),
                    ..._selectedDietaryFilters.map((filter) => Chip(
                          label: Text(filter),
                          onDeleted: () {
                            setState(() {
                              _selectedDietaryFilters.remove(filter);
                              _saveDietaryPreferences();
                            });
                          },
                          backgroundColor: const Color(0xFF2E8B57).withOpacity(0.1),
                          labelStyle: const TextStyle(color: Color(0xFF2E8B57)),
                          deleteIconColor: const Color(0xFF2E8B57),
                        )),
                  ],
                ),
              ),
            ),
          // Categories
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map(_buildCategoryChip).toList(),
                ),
              ),
            ),
          ),
          // Recipe Count
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Text(
                '${filteredRecipes.length} recipes found',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF718096),
                ),
              ),
            ),
          ),
          // Recipes Grid
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: filteredRecipes.isEmpty
                ? SliverFillRemaining(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No recipes found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Try adjusting your search or filters',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final recipe = filteredRecipes[index];
                        return _buildRecipeCard(recipe);
                      },
                      childCount: filteredRecipes.length,
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Dietary Preferences'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select your dietary preferences:'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _dietaryOptions
                        .map(_buildDietaryFilterChip)
                        .toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.filter_alt),
        backgroundColor: const Color(0xFF2E8B57),
      ),
    );
  }
}