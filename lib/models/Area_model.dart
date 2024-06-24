class Area {
  String title;
  String image;

  Area({required this.title, required this.image});

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
        title: json["demonyms"]["eng"]["m"], image: json["flags"]["png"]);
  }
}
