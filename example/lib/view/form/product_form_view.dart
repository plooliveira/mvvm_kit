import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mvvm_kit/mvvm_kit.dart';
import 'product_form_viewmodel.dart';

part 'widgets/_form_card.dart';
part 'widgets/_json_output_card.dart';

class ProductFormRoute extends GoRoute {
  ProductFormRoute()
    : super(
        path: '/product-form',
        name: 'product-form',
        builder: (context, state) => const ProductFormView(),
      );
}

class ProductFormView extends StatefulWidget {
  const ProductFormView({super.key, this.viewModel});
  final ProductFormViewModel? viewModel;

  @override
  State<ProductFormView> createState() => _ProductFormViewState();
}

class _ProductFormViewState
    extends ViewState<ProductFormViewModel, ProductFormView> {
  // A simple approach is to allow passing an optional ViewModel instance via the constructor,
  // which is useful for testing the ViewModel. But in larger apps, consider using a service locator or more advanced dependency injection.
  @override
  late final ProductFormViewModel viewModel =
      widget.viewModel ?? ProductFormViewModel();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _clearForm() {
    viewModel.clearForm();
    _nameController.clear();
    _priceController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Form Example')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FormCard(
              nameController: _nameController,
              priceController: _priceController,
              viewModel: viewModel,
            ),
            const SizedBox(height: 24),
            Watch(
              viewModel.jsonOutput,
              builder: (context, json) {
                return _JsonOutputCard(json: json);
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _clearForm,
              icon: const Icon(Icons.clear),
              label: const Text('Clear Form'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
