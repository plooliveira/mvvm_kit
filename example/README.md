# MVVM Kit Playground

This is a **demonstration playground** for the [mvvm_kit](https://pub.dev/packages/mvvm_kit) package, illustrating the practical implementation of the **MVVM (Model-View-ViewModel)** pattern combined with **LiveData** in different real-world Flutter development scenarios.

## 🎯 Purpose

The playground demonstrates how to implement the MVVM + LiveData pattern in various contexts, including:

- Reactive state management with LiveData
- Complex object manipulation with LiveData.update()
- LiveData transformations and combinations
- HotswapLiveData for dynamic data source switching
- Data layer integration using Repository Pattern
- Reactive Local database integration

## 📋 Included Examples

### 1. Counter
Basic demonstration of LiveData and loading states, ideal for understanding the pattern's fundamentals.

### 2. Theme Switcher
Demonstrates HotswapLiveData for dynamically switching between different LiveData sources at runtime.

### 3. Product Form
Demonstration of complex Objects manipulation using `LiveData.update()` for granular state updates.

### 4. Todo List
Complete example with Repository Pattern, demonstrating reactive integration with local database and CRUD operations.


## 🏗️ Project Structure

This project follows a **simple and pragmatic structure**, focused on demonstrating the use of `mvvm_kit` in a clear and didactic way:

```
lib/
├── core/           # Settings, routes and shared components
├── data/           # Models, repositories and data layer
├── view/           # Views and ViewModels
└── main.dart       # Application entry point
```

## 🚀 How to Run

1. Clone the mvvm_kit repository
2. Navigate to the example folder:
   ```bash
   cd example
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the project:
   ```bash
   flutter run
   ```

## 📚 Learning

Each example in the playground is independent and self-contained, allowing you to:

- Explore the source code of each feature
- Understand how to integrate mvvm_kit in different scenarios
- See code organization best practices
- Learn scalable architecture patterns

---

**Note:** This is an educational demonstration project. For production applications, consider adding additional layers of abstraction, comprehensive tests, and other patterns as your project's complexity requires.
