import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part './widgets/_exemplo_card.dart';

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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ExampleCard(
                title: '1. Counter',
                description: 'Basic LiveData + Loading States',
                icon: Icons.add_circle_outline,
                onTap: () => context.push('/counter'),
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
                description: 'ObjectBox + Repository pattern',
                icon: Icons.checklist_outlined,
                onTap: () => context.push('/todo'),
                enabled: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
