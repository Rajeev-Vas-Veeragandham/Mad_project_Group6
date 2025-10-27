import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/openai_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AISuggestionsScreen extends StatefulWidget {
  const AISuggestionsScreen({Key? key}) : super(key: key);

  @override
  _AISuggestionsScreenState createState() => _AISuggestionsScreenState();
}

class _AISuggestionsScreenState extends State<AISuggestionsScreen> {
  final _prefsCtl = TextEditingController();
  bool _loading = false;
  String _error = '';
  List<Map<String, dynamic>> _suggestions = [];

  Future<void> _fetchSuggestions() async {
    if (_prefsCtl.text.trim().isEmpty) {
      setState(() {
        _error = 'Please tell me what you\'re craving!';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
      _suggestions = [];
    });

    try {
      final openaiKey = dotenv.env['OPENAI_KEY'] ?? '';
      
      if (openaiKey.isEmpty || openaiKey == 'your_openai_key_here') {
        // Use enhanced mock data when no API key
        await _useEnhancedMockData();
      } else {
        // Use real API
        final openai = OpenAIService(openaiKey);
        final content = await openai.generateRecipeSuggestions(
          userPreferences: _prefsCtl.text,
        );
        _parseAISuggestions(content);
      }

    } catch (e) {
      print('AI Error: $e');
      // Fallback to mock data on error
      await _useEnhancedMockData();
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // Enhanced mock data with better recipes
  Future<void> _useEnhancedMockData() async {
    await Future.delayed(const Duration(seconds: 2));
    
    final query = _prefsCtl.text.toLowerCase();
    
    List<Map<String, dynamic>> mockData = [];
    
    if (query.contains('vegan') || query.contains('plant')) {
      mockData = [
        {
          'title': '🌱 Vegan Buddha Bowl',
          'summary': 'Colorful bowl with quinoa, roasted vegetables, avocado, and tahini dressing',
          'ingredients': ['1 cup quinoa', '2 cups mixed vegetables', '1 avocado', '3 tbsp tahini', '1 lemon', '2 tbsp olive oil', 'Salt and pepper'],
          'prepTime': 15,
          'cookTime': 25,
          'difficulty': 'Easy',
          'calories': 420,
          'dietaryTags': ['vegan', 'gluten-free']
        },
        {
          'title': '🥑 Creamy Avocado Pasta',
          'summary': 'Creamy pasta sauce made from avocado, basil, and lemon juice',
          'ingredients': ['200g spaghetti', '2 ripe avocados', '1/2 cup basil', '3 cloves garlic', '2 tbsp lemon juice', '3 tbsp olive oil', 'Salt'],
          'prepTime': 10,
          'cookTime': 12,
          'difficulty': 'Easy',
          'calories': 380,
          'dietaryTags': ['vegan']
        },
      ];
    } else if (query.contains('quick') || query.contains('easy')) {
      mockData = [
        {
          'title': '🍳 15-Minute Stir Fry',
          'summary': 'Quick and healthy vegetable stir fry with tofu in savory sauce',
          'ingredients': ['200g tofu', '3 cups mixed vegetables', '2 tbsp soy sauce', '1 tbsp sesame oil', '2 cloves garlic', '1 tbsp ginger'],
          'prepTime': 5,
          'cookTime': 10,
          'difficulty': 'Easy',
          'calories': 320,
          'dietaryTags': ['vegetarian']
        },
      ];
    } else {
      // Default suggestions
      mockData = [
        {
          'title': '🍝 Creamy Mushroom Pasta',
          'summary': 'Rich and creamy pasta with wild mushrooms and parmesan',
          'ingredients': ['200g fettuccine', '300g mushrooms', '1 cup cream', '1/2 cup parmesan', '3 cloves garlic', '2 tbsp butter', 'Fresh parsley'],
          'prepTime': 10,
          'cookTime': 20,
          'difficulty': 'Medium',
          'calories': 450,
          'dietaryTags': ['vegetarian']
        },
        {
          'title': '🍗 Mediterranean Chicken',
          'summary': 'Juicy chicken with tomatoes, olives, and herbs',
          'ingredients': ['2 chicken breasts', '1 cup cherry tomatoes', '1/2 cup olives', '3 tbsp olive oil', '2 cloves garlic', 'Fresh oregano'],
          'prepTime': 15,
          'cookTime': 25,
          'difficulty': 'Medium',
          'calories': 380,
          'dietaryTags': []
        },
        {
          'title': '🍫 Chocolate Avocado Mousse',
          'summary': 'Decadent chocolate mousse made with avocado - healthy and delicious!',
          'ingredients': ['2 ripe avocados', '1/4 cup cocoa powder', '1/4 cup maple syrup', '1 tsp vanilla', 'Pinch of salt', 'Fresh berries'],
          'prepTime': 10,
          'cookTime': 0,
          'difficulty': 'Easy',
          'calories': 280,
          'dietaryTags': ['vegan', 'gluten-free']
        },
      ];
    }
    
    setState(() {
      _suggestions = mockData;
    });
  }

  void _parseAISuggestions(String content) {
    try {
      final parsed = jsonDecode(content);
      if (parsed is List) {
        _suggestions = List<Map<String, dynamic>>.from(
            parsed.map((e) => Map<String, dynamic>.from(e)));
      }
    } catch (e) {
      // If JSON parsing fails, use mock data
      _useEnhancedMockData();
    }
  }

  @override
  void dispose() {
    _prefsCtl.dispose();
    super.dispose();
  }

  Widget _buildRecipeCard(Map<String, dynamic> suggestion, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header with gradient
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF2E8B57).withOpacity(0.8),
                    const Color(0xFFFF6B6B).withOpacity(0.6),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Text(
                  suggestion['title']?.toString() ?? 'AI Recipe',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion['summary']?.toString() ?? 'No description',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF718096),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Recipe info chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (suggestion['prepTime'] != null)
                        Chip(
                          label: Text('${suggestion['prepTime']} min prep'),
                          visualDensity: VisualDensity.compact,
                          backgroundColor: const Color(0xFF2E8B57).withOpacity(0.1),
                          labelStyle: const TextStyle(color: Color(0xFF2E8B57), fontSize: 12),
                        ),
                      if (suggestion['cookTime'] != null)
                        Chip(
                          label: Text('${suggestion['cookTime']} min cook'),
                          visualDensity: VisualDensity.compact,
                          backgroundColor: const Color(0xFFFF6B6B).withOpacity(0.1),
                          labelStyle: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 12),
                        ),
                      if (suggestion['difficulty'] != null)
                        Chip(
                          label: Text(suggestion['difficulty']),
                          visualDensity: VisualDensity.compact,
                          backgroundColor: const Color(0xFFFFD166).withOpacity(0.1),
                          labelStyle: const TextStyle(color: Color(0xFFB38B2D), fontSize: 12),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Ingredients preview
                  const Text(
                    'Key Ingredients:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...(suggestion['ingredients'] as List<dynamic>?)
                      ?.take(4)
                      .map((ingredient) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2E8B57),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    ingredient.toString(),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList() ??
                      [const Text('No ingredients listed')],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Recipe Suggestions'),
        backgroundColor: const Color(0xFF2E8B57),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input
            TextField(
              controller: _prefsCtl,
              decoration: const InputDecoration(
                labelText: 'What are you craving? (e.g., "vegan dinner", "quick lunch", "Italian pasta")',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: (_) => _fetchSuggestions(),
            ),
            
            const SizedBox(height: 20),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loading ? null : _fetchSuggestions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E8B57),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.auto_awesome, size: 20),
                              SizedBox(width: 8),
                              Text('Get AI Suggestions', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    _prefsCtl.clear();
                    setState(() {
                      _error = '';
                      _suggestions = [];
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Clear', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Error Message
            if (_error.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _error,
                        style: const TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 20),
            
            // Suggestions Title
            if (_suggestions.isNotEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '🤖 AI-Generated Recipes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Suggestions List
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'AI is cooking up delicious suggestions...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'This may take a few seconds',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_suggestions.isEmpty && _error.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'Tell me what you want to cook!',
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'Try these examples:\n• "vegan dinner ideas"\n• "quick and easy lunch"\n• "healthy breakfast options"\n• "Italian pasta recipes"',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        return _buildRecipeCard(_suggestions[index], index);
      },
    );
  }
}