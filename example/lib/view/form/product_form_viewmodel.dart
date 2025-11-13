import 'dart:convert';
import 'package:example_playground/data/models/product.dart';
import 'package:mvvm_kit/mvvm_kit.dart';

class ProductFormViewModel extends ViewModel {
  late final _product = mutable(
    ProductModel(name: '', price: 0.0, available: false),
  );
  LiveData<ProductModel> get product => _product;

  late final jsonOutput = product.transform(
    (data) => const JsonEncoder.withIndent('  ').convert(data.value.toJson()),
  );

  void updateName(String name) {
    _product.update((p) => p.name = name);
  }

  void updatePrice(String value) {
    final price = double.tryParse(value) ?? 0.0;
    _product.update((p) => p.price = price);
  }

  void toggleAvailable(bool? value) {
    _product.update((p) => p.available = value ?? false);
  }

  void clearForm() {
    _product.value = ProductModel(name: '', price: 0.0, available: false);
  }
}
