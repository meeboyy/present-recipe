import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:present_recipe/RecipeListPage.dart';
import 'package:present_recipe/models/Area_model.dart';
import 'package:present_recipe/models/Category_model.dart';
import 'package:present_recipe/models/Ingredient_model.dart';
import 'package:present_recipe/services/Connections.dart';

class CategoryPage extends StatefulWidget {
  late final String filter;

  CategoryPage({required this.filter});
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late Future<List<Category>> futureCategories;
  late Future<List<Area>> futureArea;
  late Future<List<String>> areaName;
  late List<dynamic> filteredCategories;
  late String filter;
  late Future<dynamic> futureData;

  TextEditingController _controller = TextEditingController();
  Connection _connection = Connection();

  @override
  void initState() {
    super.initState();
    filter = widget.filter;
    if (filter == "region") {
      areaName = _connection.fetchAreaName();
      futureData = areaName;
    } else if (filter == "category") {
      futureCategories = _connection.fetchCategories();
      futureData = futureCategories;
    } else {
      futureData = _connection.fetchIngredient();
    }
    futureData.then((value) {
      setState(() {
        filteredCategories = value;
      });
    });
  }

  Future<void> filterCategories(String query) async {
    List<Category> filteredList = await futureCategories.then((categorys) {
      return categorys
          .where((category) =>
              category.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });

    setState(() {
      filteredCategories = filteredList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  filter.toUpperCase(),
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
                    filterCategories(value);
                  },
                ),
              ],
            ),
          ),
          FutureBuilder(
            future: futureData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No categories found.'));
              } else {
                return Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2),
                    padding: EdgeInsets.all(10),
                    itemCount: filteredCategories.length,
                    itemBuilder: (context, index) {
                      if (filter == 'region') {
                        return GestureDetector(
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return RecipeListPage(
                                listName: "area",
                                keyName: filteredCategories[index]);
                          })),
                          child: Card(
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(filteredCategories[index]),
                            ),
                          ),
                        );
                        // futureArea = _connection.fetchArea(snapshot.data[index]);
                        // return FutureBuilder(
                        //     future: futureArea,
                        //     builder: (context, shot) {
                        //       if (shot.connectionState == ConnectionState.waiting) {
                        //         return Center(child: CircularProgressIndicator());
                        //       } else if (shot.hasError) {
                        //         return Center(child: Text('Error: ${shot.error}'));
                        //       } else if (!shot.hasData || shot.data!.isEmpty) {
                        //         return Center(child: Text('No categories found.'));
                        //       } else {
                        //         final area = shot.data![index];
                        //         return byRegion(area);
                        //       }
                        //     });
                      } else if (filter == 'category') {
                        final category = filteredCategories[index];
                        return GestureDetector(
                          child: byCategory(category),
                          onTap: () {
                            // Navigate to the recipe list page for this category
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return RecipeListPage(
                                    listName: "category",
                                    keyName: category.title);
                              }),
                            );
                          },
                        );
                      } else {
                        Ingredient ingredient = filteredCategories[index];
                        String imageLink =
                            'https://www.themealdb.com/images/ingredients/${ingredient.title}.png';
                        return GestureDetector(
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return RecipeListPage(
                                listName: "ingredients",
                                keyName: ingredient.title);
                          })),
                          child: Card(
                            child: Container(
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: imageLink,
                                    height: 100,
                                    width: 100,
                                    placeholder: ((context, url) =>
                                        CircularProgressIndicator()),
                                  ),
                                  Text(ingredient.title),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget byCategory(Category category) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                category.imageUrl,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            Text(category.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('${category.recipeCount} Resep'),
          ],
        ));
  }

  Widget byRegion(Area area) {
    return GestureDetector(
      onTap: () {
        // Navigate to the recipe list page for this category
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RecipeListPage(listName: 'area', keyName: area.title),
          ),
        );
      },
      child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  area.image,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              Text(area.title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
            ],
          )),
    );
  }
}
