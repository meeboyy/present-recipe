import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:present_recipe/models/Detail_model.dart';
import 'package:present_recipe/models/Recipe_model.dart';

class RecipeDetailPage extends StatefulWidget {
  final String recipeId;

  RecipeDetailPage({required this.recipeId});

  @override
  _RecipeDetailPageState createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  late Future<DetailRecipe> futureRecipe;

  @override
  void initState() {
    super.initState();
    futureRecipe = fetchRecipeDetail(widget.recipeId);
  }

  Future<DetailRecipe> fetchRecipeDetail(String id) async {
    final response = await http.get(
        Uri.parse('https://www.themealdb.com/api/json/v1/1/lookup.php?i=$id'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body)['meals'][0];
      return DetailRecipe.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load recipe');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DetailRecipe>(
      future: futureRecipe,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
              color: Colors.white,
              child: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('No recipe found.'));
        } else {
          final recipe = snapshot.data!;
          return Stack(fit: StackFit.expand, children: [
            Card(
              elevation: 0,
              child: Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.43),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text('Deskripsi',
                        //     style: TextStyle(
                        //         fontSize: 18, fontWeight: FontWeight.bold)),
                        // Text(recipe.description),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.17),
                        Text('Bahan-bahan'.toUpperCase(),
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        for (var ingredient in recipe.ingredients)
                          ListTile(
                            leading: Container(
                              child: Image.network(
                                'https://www.themealdb.com/images/ingredients/${ingredient}-small.png',
                                width: 30,
                                height: 30,
                              ),
                            ),
                            title: Text(ingredient.replaceFirst(
                                ingredient[0], ingredient[0].toUpperCase())),
                          ),
                        SizedBox(height: 16),
                        Text('Langkah-langkah',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        for (var step in recipe.steps)
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.orange,
                              child: Text('${recipe.steps.indexOf(step) + 1}',
                                  style: TextStyle(color: Colors.white)),
                            ),
                            title: Text(step),
                          ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Logic to save recipe to favorites
                          },
                          child: Text('Simpan ke Favorit'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
                bottom: MediaQuery.of(context).size.height * 0.55,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24)),
                  child: Container(
                      alignment: Alignment.bottomRight,
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Image.network(
                        recipe.imageUrl,
                        fit: BoxFit.cover,
                      )),
                )),
            Align(
                alignment: Alignment.center,
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                    Radius.circular(32),
                  )),
                  child: Container(
                    width: 350,
                    height: 170,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(recipe.title.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        RatingBarIndicator(
                          rating: recipe.rating,
                          itemBuilder: (context, index) =>
                              Icon(Icons.star, color: Colors.amber),
                          itemCount: 5,
                          itemSize: 20.0,
                          direction: Axis.horizontal,
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_clock,
                              color: Colors.orange,
                            ),
                            Text('  ${recipe.cookingTime} menit'),
                            SizedBox(
                              width: 50,
                            ),
                            Icon(
                              Icons.live_help,
                              color: Colors.orange,
                            ),
                            Text('  ${recipe.difficulty}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
            Align(
              alignment: Alignment.topRight,
              child: Card(
                  color: Colors.transparent,
                  elevation: 0,
                  child: IconButton(
                    iconSize: 32,
                    icon: Icon(Icons.close_outlined),
                    onPressed: () => Navigator.pop(context),
                  )),
            )
          ]);
        }
      },
    );
  }
}
