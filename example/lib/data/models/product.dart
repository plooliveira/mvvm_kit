class ProductModel {
  String name;
  double price;
  bool available;

  ProductModel({
    required this.name,
    required this.price,
    required this.available,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price,
    'available': available,
  };
}
