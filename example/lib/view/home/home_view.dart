import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part './widgets/_exemplo_card.dart';

class HomeRoute extends GoRoute {
  HomeRoute()
    : super(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeView(),
      );
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MVVM Kit Playground',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ExampleCard(
              title: '1. Counter (Cascade)',
              description:
                  'Basic ViewModel + LiveData and ViewWidget with cascade state',
              icon: Icons.add_circle_outline,
              onTap: () => context.push('/counter-cascade'),
            ),

            const SizedBox(height: 16),
            _ExampleCard(
              title: '1. Counter',
              description:
                  'Basic ViewModel + LiveData + ViewState with loading states',
              icon: Icons.add_circle_outline,
              onTap: () => context.push('/counter'),
            ),

            const SizedBox(height: 16),

            _ExampleCard(
              title: '4. Product Form',
              description: 'LiveData.update() demonstration',
              icon: Icons.edit_document,
              onTap: () => context.push('/product-form'),
              enabled: true,
            ),

            const SizedBox(height: 16),

            _ExampleCard(
              title: '2. Theme Switcher',
              description: 'HotswapLiveData demonstration',
              icon: Icons.palette_outlined,
              onTap: () => context.push('/theme'),
              enabled: true,
            ),

            const SizedBox(height: 16),

            _ExampleCard(
              title: '3. Todo List',
              description: 'Reactive DB + RepositoryData',
              icon: Icons.checklist_outlined,
              onTap: () => context.push('/todo'),
              enabled: true,
            ),
          ],
        ),
      ),
    );
  }
}
