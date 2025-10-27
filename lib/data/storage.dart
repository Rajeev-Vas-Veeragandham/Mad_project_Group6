import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal_plan.dart';

class Storage {
  static const _favKey = 'fav_recipes_v2';
  static const _mealPlanKey = 'meal_plan_v2';
  static const _dietaryPrefsKey = 'dietary_prefs_v1';
  static const _userPreferencesKey = 'user_prefs_v1';

  // Favorites
  static Future<Set<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_favKey);
    if (list == null) return <String>{};
    return list.toSet();
  }

  static Future<void> saveFavorites(Set<String> favs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favKey, favs.toList());
  }

  // MealPlan
  static Future<void> saveMealPlan(MealPlan plan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_mealPlanKey, jsonEncode(plan.toJson()));
  }

  static Future<MealPlan?> loadMealPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_mealPlanKey);
    if (s == null) return null;
    try {
      return MealPlan.fromJson(jsonDecode(s));
    } catch (e) {
      return null;
    }
  }

  // Dietary Preferences
  static Future<void> saveDietaryPreferences(Set<String> prefs) async {
    final sharedPrefs = await SharedPreferences.getInstance();
    await sharedPrefs.setStringList(_dietaryPrefsKey, prefs.toList());
  }

  static Future<Set<String>> loadDietaryPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_dietaryPrefsKey);
    if (list == null) return <String>{};
    return list.toSet();
  }

  // User Preferences for AI
  static Future<void> saveUserPreferences(String preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userPreferencesKey, preferences);
  }

  static Future<String> loadUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userPreferencesKey) ?? '';
  }
}