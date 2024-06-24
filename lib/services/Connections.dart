import 'dart:convert';
import 'dart:math';

import 'package:present_recipe/models/Area_model.dart';
import 'package:present_recipe/models/Category_model.dart';
import 'package:present_recipe/models/Ingredient_model.dart';
import 'package:present_recipe/models/Recipe_model.dart';
import 'package:http/http.dart' as http;

class Connection {
  Future<List<Recipe>> fetchRecipes(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List jsonResponse = json.decode(response.body)['meals'];
      return jsonResponse.map((recipe) => Recipe.fromJson(recipe)).toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  Future<List<Recipe>> searchRecipe(String query) async {
    final response = await http.get(Uri.parse(
        'https://www.themealdb.com/api/json/v1/1/search.php?s=$query'));

    if (response.statusCode == 200) {
      dynamic responses = json.decode(response.body)['meals'];
      if (responses == null) {
        return [];
      } else {
        final List jsonResponse = json.decode(response.body)['meals'];

        return jsonResponse.map((e) => Recipe.fromJson(e)).toList();
      }
    } else {
      throw Exception('Failed');
    }
  }

  Future<List<Category>> fetchCategories() async {
    final response = await http.get(
        Uri.parse('https://www.themealdb.com/api/json/v1/1/categories.php'));

    if (response.statusCode == 200) {
      final List jsonResponse = json.decode(response.body)['categories'];
      List<Category> categories =
          jsonResponse.map((category) => Category.fromJson(category)).toList();

      // Update recipe count for each category
      for (var category in categories) {
        final countResponse = await http.get(Uri.parse(
            'https://www.themealdb.com/api/json/v1/1/filter.php?c=${category.title}'));
        if (countResponse.statusCode == 200) {
          final countJsonResponse = json.decode(countResponse.body)['meals'];
          category.recipeCount = countJsonResponse.length;
        }
      }

      return categories;
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<List<Recipe>> fetchRecipesByCategory(String category) async {
    final response = await http.get(Uri.parse(
        'https://www.themealdb.com/api/json/v1/1/filter.php?c=$category'));

    if (response.statusCode == 200) {
      final List jsonResponse = json.decode(response.body)['meals'];
      return jsonResponse.map((recipe) => Recipe.fromJson(recipe)).toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  Future<List<Recipe>> fetchRecipesByIngredients(String ingredient) async {
    final response = await http.get(Uri.parse(
        'https://www.themealdb.com/api/json/v1/1/filter.php?i=$ingredient'));

    if (response.statusCode == 200) {
      final List jsonResponse = json.decode(response.body)['meals'];
      return jsonResponse.map((recipe) => Recipe.fromJson(recipe)).toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  Future<List<Recipe>> fetchRecipesByArea(String area) async {
    final response = await http.get(Uri.parse(
        'https://www.themealdb.com/api/json/v1/1/filter.php?a=$area'));

    if (response.statusCode == 200) {
      final List jsonResponse = json.decode(response.body)['meals'];
      return jsonResponse.map((recipe) => Recipe.fromJson(recipe)).toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  Future<List<Ingredient>> fetchIngredient() async {
    final response = await http.get(
        Uri.parse('https://www.themealdb.com/api/json/v1/1/list.php?i=list'));

    if (response.statusCode == 200) {
      final List jsonResponse = json.decode(response.body)['meals'];
      return jsonResponse.map((e) => Ingredient.fromJson(e)).toList();
    } else {
      throw Exception('error');
    }
  }

  Future<List<String>> fetchAreaName() async {
    final response = await http.get(
        Uri.parse('https://www.themealdb.com/api/json/v1/1/list.php?a=list'));

    if (response.statusCode == 200) {
      final List jsonResponse = json.decode(response.body)['meals'];
      var areaList = jsonResponse.map((areas) => areas['strArea'] as String);
      return areaList.toList();
    } else {
      throw Exception("Failed");
    }
  }

  Future<List<Area>> fetchArea(String value) async {
    Future<List> area = fetchAreaName();

    return area.then((value) async {
      log(value.single);
      final responseArea = await http
          .get(Uri.parse('https://restcountries.com/v3.1/demonym/$value'));

      if (responseArea.statusCode == 200) {
        final List jsonResponses = json.decode(responseArea.body);
        return jsonResponses.map((e) => Area.fromJson(e)).toList();
      } else {
        throw Exception("Failed");
      }
    });
  }
}
