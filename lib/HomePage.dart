import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:present_recipe/CategoryPage.dart';
import 'package:present_recipe/RecipeDetail.dart';
import 'package:present_recipe/models/Category_model.dart';
import 'package:present_recipe/models/Recipe_model.dart';
import 'package:present_recipe/services/connections.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Connection _connection = Connection();
  late Future<List<Recipe>> futurePopularRecipes;
  late Future<List<Category>> futureCategories;
  late Future<List<Recipe>> futureRecentRecipes;

  List categoryTile = [
    {"title": "Region", "icon": Icons.flag, "filter": "region"},
    {"title": "Category", "icon": Icons.food_bank, "filter": "category"},
    {"title": "Ingredients", "icon": Icons.category, "filter": "ingredients"},
  ];

  @override
  void initState() {
    super.initState();

    futurePopularRecipes = _connection
        .fetchRecipes('https://www.themealdb.com/api/json/v1/1/random.php');
    futureCategories = _connection.fetchCategories();
    futureRecentRecipes = _connection
        .fetchRecipes('https://www.themealdb.com/api/json/v1/1/search.php?f=b');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        clipBehavior: Clip.none,
        child: Padding(
          padding: const EdgeInsets.only(top: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "PRECIPE",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                    ),
                    IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        showSearch(
                            context: context, delegate: RecipeSearchDelegate());
                      },
                    ),
                  ],
                ),
              ),
              FutureBuilder<List<Recipe>>(
                future: futurePopularRecipes,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No popular recipes found.'));
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CarouselSlider(
                        options: CarouselOptions(height: 200, autoPlay: true),
                        items: snapshot.data!.map((recipe) {
                          return Builder(
                            builder: (BuildContext context) {
                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: 5.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl: recipe.imageUrl,
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        child: Container(
                                          color: Colors.deepOrangeAccent
                                              .withOpacity(0.7),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          padding: EdgeInsets.all(10),
                                          child: Text(
                                            recipe.title,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    );
                  }
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SectionTitle(title: 'Kategori Resep'),
                  // TextButton(
                  //     onPressed: () {
                  //       Navigator.push(context,
                  //           MaterialPageRoute(builder: (context) {
                  //         return CategoryPage();
                  //       }));
                  //     },
                  //     child: Text("Show all.."))
                ],
              ),
              Container(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categoryTile.length,
                  itemBuilder: (context, index) {
                    return CategoryTile(
                      title: categoryTile[index]["title"],
                      icon: categoryTile[index]["icon"],
                      filter: categoryTile[index]["filter"],
                    );
                  },
                ),
              ),
              // FutureBuilder<List<Category>>(
              //   future: futureCategories,
              //   builder: (context, snapshot) {
              //     if (snapshot.connectionState == ConnectionState.waiting) {
              //       return Center(child: CircularProgressIndicator());
              //     } else if (snapshot.hasError) {
              //       return Center(child: Text('Error: ${snapshot.error}'));
              //     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              //       return Center(child: Text('No categories found.'));
              //     } else {
              //       return Container(
              //         height: 100,
              //         child: ListView.builder(
              //           scrollDirection: Axis.horizontal,
              //           itemCount: 5,
              //           itemBuilder: (context, index) {
              //             final category = snapshot.data![index];
              //             return CategoryCard(category: category);
              //           },
              //         ),
              //       );
              //     }
              //   },
              // ),
              SectionTitle(title: 'Resep Terbaru'),
              FutureBuilder<List<Recipe>>(
                future: futureRecentRecipes,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No recent recipes found.'));
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.all(10),
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        final recipe = snapshot.data![index];
                        return RecipeCard(recipe: recipe);
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final String filter;

  CategoryTile({required this.title, required this.icon, required this.filter});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return CategoryPage(filter: filter);
        }));
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 10, bottom: 10),
        child: Column(
          children: [
            Card(
              shape: CircleBorder(),
              color: Colors.deepOrange,
              child: Container(
                width: 50,
                height: 50,
                child: Icon(
                  icon,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 10),
            )
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final Category category;

  CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: category.imageUrl,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 5),
          Text(
            category.title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final Recipe recipe;

  RecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (context) {
        return RecipeDetailPage(recipeId: recipe.id);
      })),
      child: Card(
        color: Colors.deepOrange,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        child: Container(
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius:
                    BorderRadius.horizontal(left: Radius.circular(15)),
                child: CachedNetworkImage(
                  imageUrl: recipe.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  recipe.title,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecipeSearchDelegate extends SearchDelegate {
  Connection _connection = Connection();

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    Future<List<Recipe>> futureRecipe = _connection.searchRecipe(query);
    return FutureBuilder(
      future: futureRecipe,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No items found.'));
        } else {
          List<Recipe> recipes = snapshot.data;
          return ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                return Text(recipes[index].title);
              });
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    Future<List<Recipe>> futureRecipe = _connection.searchRecipe(query);
    return FutureBuilder(
      future: futureRecipe,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No items found.'));
        } else {
          List<Recipe> recipes = snapshot.data;
          return ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                Recipe recipe = recipes[index];
                return GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) {
                    return RecipeDetailPage(recipeId: recipe.id);
                  })),
                  child: Card(
                    color: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    child: Container(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(15)),
                            child: CachedNetworkImage(
                              imageUrl: recipe.imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                recipe.title,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              });
        }
      },
    );
  }
}
