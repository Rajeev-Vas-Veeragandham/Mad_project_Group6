import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String apiKey;
  static const _base = 'https://api.openai.com/v1';

  OpenAIService(this.apiKey);

  /// Generates recipe suggestions from OpenAI as JSON string
  Future<String> generateRecipeSuggestions({
    required String userPreferences,
    int maxTokens = 800,
  }) async {
    final url = Uri.parse('$_base/chat/completions');
    
    final systemPrompt = '''
You are a professional chef and nutritionist. Generate recipe suggestions in valid JSON format only.
Return exactly 3 recipes as a JSON array. Each recipe should have:
- title: string with emoji (e.g., "🥑 Avocado Toast")
- summary: string describing the recipe
- ingredients: array of 6 ingredient strings
- instructions: array of 5-7 step strings
- dietaryTags: array of dietary tags (e.g., ["vegetarian", "gluten-free"])
- prepTime: number in minutes
- cookTime: number in minutes
- difficulty: string ("Easy", "Medium", "Hard")
- calories: number

User preferences: $userPreferences

Respond ONLY with valid JSON, no other text.
''';

    final body = {
      'model': 'gpt-4o-mini',
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {
          'role': 'user',
          'content': 'Generate 3 recipe suggestions based on: $userPreferences'
        }
      ],
      'max_tokens': maxTokens,
      'temperature': 0.7,
    };

    try {
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey'
        },
        body: jsonEncode(body),
      );
      
      if (res.statusCode != 200) {
        throw Exception('OpenAI API error: ${res.statusCode} - ${res.body}');
      }
      
      final data = jsonDecode(res.body);
      final content = data['choices'][0]['message']['content'] ?? '';
      
      return content.toString();
    } catch (e) {
      throw Exception('Failed to connect to OpenAI: $e');
    }
  }

  /// Alternative method for meal planning suggestions
  Future<String> generateMealPlanSuggestions({
    required String dietaryRestrictions,
    required int days,
  }) async {
    final url = Uri.parse('$_base/chat/completions');
    
    final prompt = '''
Create a $days-day meal plan considering: $dietaryRestrictions.
Return as JSON with days containing breakfast, lunch, dinner.
Each meal should have recipe title and brief description.
''';

    final body = {
      'model': 'gpt-4o-mini',
      'messages': [
        {'role': 'user', 'content': prompt}
      ],
      'max_tokens': 1000,
      'temperature': 0.7,
    };

    final res = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey'
      },
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      throw Exception('OpenAI error: ${res.body}');
    }
    
    final data = jsonDecode(res.body);
    return data['choices'][0]['message']['content'];
  }
}