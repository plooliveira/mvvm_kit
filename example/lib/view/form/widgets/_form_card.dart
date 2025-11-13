part of '../product_form_view.dart';

class _FormCard extends StatelessWidget {
  const _FormCard();

  @override
  Widget build(BuildContext context) {
    final viewModel = context
        .findAncestorStateOfType<_ProductFormViewState>()!
        .viewModel;

    final nameController = context
        .findAncestorStateOfType<_ProductFormViewState>()!
        ._nameController;

    final priceController = context
        .findAncestorStateOfType<_ProductFormViewState>()!
        ._priceController;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.shopping_bag),
              ),
              onChanged: viewModel.updateName,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
                prefixText: 'R\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              onChanged: viewModel.updatePrice,
            ),
            const SizedBox(height: 8),
            Watch(
              viewModel.product,
              builder: (context, product) {
                return CheckboxListTile(
                  title: const Text('Available in Stock'),
                  value: product.available,
                  onChanged: viewModel.toggleAvailable,
                  secondary: const Icon(Icons.inventory),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
