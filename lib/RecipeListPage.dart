import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:present_recipe/RecipeDetail.dart';
import 'package:present_recipe/models/Recipe_model.dart';
import 'package:present_recipe/services/Connections.dart';

import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RecipeListPage extends StatefulWidget {
  final String listName;
  final String keyName;

  RecipeListPage({required this.listName, required this.keyName});

  @override
  _RecipeListPageState createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  Connection _connection = Connection();
  late Future<List<Recipe>> futureRecipes;
  late String _listName;
  late List<Recipe> filteredRecipes;
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _listName = widget.listName;
    if (_listName == 'category')
      futureRecipes = _connection.fetchRecipesByCategory(widget.keyName);
    else if (_listName == 'ingredients') {
      futureRecipes = _connection.fetchRecipesByIngredients(widget.keyName);
    } else {
      futureRecipes = _connection.fetchRecipesByArea(widget.keyName);
    }

    futureRecipes.then((value) {
      setState(() {
        filteredRecipes = value;
      });
    });
  }

  Future<void> filterRecipe(String query) async {
    List<Recipe> filterRecipes = await futureRecipes.then((value) => value
        .where((element) =>
            element.title.toLowerCase().contains(query.toLowerCase()))
        .toList());

    setState(() {
      filteredRecipes = filterRecipes;
    });
  }

  void sortRecipes(List<Recipe> recipes, String sortBy) {
    switch (sortBy) {
      case 'Rating':
        // Sort by rating
        recipes.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Cooking Time':
        // Sort by cooking time
        recipes.sort((a, b) => a.cookingTime.compareTo(b.cookingTime));
        break;
      case 'Difficulty':
        // Sort by difficulty
        recipes.sort((a, b) => a.difficulty.compareTo(b.difficulty));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    String sortBy = 'Rating';
    String name = widget.keyName;
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Daftar Resep - ${widget.category}'),
      //   backgroundColor: Colors.transparent,
      //   actions: [
      //     PopupMenuButton<String>(
      //       onSelected: (String value) {
      //         setState(() {
      //           sortBy = value;
      //         });
      //       },
      //       itemBuilder: (BuildContext context) {
      //         return ['Rating', 'Cooking Time', 'Difficulty']
      //             .map((String choice) {
      //           return PopupMenuItem<String>(
      //             value: choice,
      //             child: Text(choice),
      //           );
      //         }).toList();
      //       },
      //     ),
      //   ],
      // ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_new),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              IconButton(
                icon: Icon(Icons.filter_list),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$name",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32),
                ),
                SizedBox(
                  height: 12,
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  controller: _controller,
                  onChanged: (value) {
                    filterRecipe(value);
                  },
                ),
              ],
            ),
          ),
          FutureBuilder<List<Recipe>>(
            future: futureRecipes,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No recipes found.'));
              } else {
                return Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.all(10),
                    itemCount: filteredRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = filteredRecipes[index];
                      return RecipeCard(recipe);
                    },
                  ),
                );
                // return ListView.builder(
                //   padding: EdgeInsets.all(10),
                //   itemCount: recipes.length,
                //   itemBuilder: (context, index) {
                //     final recipe = recipes[index];
                // return Card(
                //   shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.circular(15),
                //   ),
                //   elevation: 5,
                //   child: ListTile(
                //     leading: ClipRRect(
                //       borderRadius: BorderRadius.circular(10),
                //       child: Image.network(
                //         recipe.imageUrl,
                //         width: 50,
                //         height: 50,
                //         fit: BoxFit.cover,
                //       ),
                //     ),
                //     title: Text(recipe.title,
                //         style: TextStyle(
                //             fontSize: 18, fontWeight: FontWeight.bold)),
                //     subtitle: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         RatingBarIndicator(
                //           rating: recipe.rating,
                //           itemBuilder: (context, index) => Icon(
                //             Icons.star,
                //             color: Colors.amber,
                //           ),
                //           itemCount: 5,
                //           itemSize: 20.0,
                //           direction: Axis.horizontal,
                //         ),
                //         Text('Waktu memasak: ${recipe.cookingTime} menit'),
                //       ],
                //     ),
                //     onTap: () {
                //       // Navigate to the recipe detail page
                //       Navigator.push(context,
                //           MaterialPageRoute(builder: (context) {
                //         return RecipeDetailPage(recipeId: recipe.id);
                //       }));
                //     },
                //   ),
                // );
                //   },
                // );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget RecipeCard(Recipe recipe) {
    return GestureDetector(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (context) {
        return RecipeDetailPage(recipeId: recipe.id);
      })),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: Container(
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(18),
            ),
            color: Colors.orange,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 250,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          overflow: TextOverflow.clip),
                    ),
                    Text(recipe.difficulty),
                    Text(recipe.cookingTime.toString())
                  ],
                ),
              ),
              ClipRRect(
                  borderRadius: BorderRadius.circular(70),
                  child: CachedNetworkImage(
                    imageUrl: recipe.imageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.fill,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
