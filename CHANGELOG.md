## 0.13.1
### Features
- **ViewModel**: Make `ViewModel` extend `ChangeNotifier` and automatically rebuild `ViewState` on notifications. This gives the flexibility to update the entire view when a property changes.

### Doc
- Updated README

## 0.13.0
### Features
- **ViewWidget**: Introduced `ViewWidget` as a simplified alternative to `ViewState` for common use cases.
  - Streamlined API with just `build()` and optional `onInit()` methods
  - Automatic ViewModel lifecycle management (initialization and disposal)
  - Automatic LiveData scope cleanup when widget is disposed
  - Enables Cascade State Composition (CSC) pattern where each widget maintains isolated state while reactively injecting data to children via constructor props
  - Override `resolveViewModel()` for custom ViewModel injection (useful for testing)

### Documentation
- Added comprehensive documentation for ViewWidget
- Updated `ViewState` documentation to clarify when to use it vs `ViewWidget`
- Improved README with examples of both `ViewWidget` and `ViewState` usage

### Refactor
- Renamed `debugLog` parameter from `ifTrue` to `condition` for better clarity

## 0.12.0
### Performance
- **LiveData**: Changed default change detection from `DeepCollectionEquality` (O(N)) to simple equality `!=` (O(1)). This significantly improves performance for large collections.
- **GroupWatch**: Implemented microtask debouncing to prevent multiple rebuilds when multiple notifiers change in the same frame.

### Breaking Changes
- **LiveData**: Assigning the same instance of a mutable object (e.g., `List`, `Map`) to a `MutableLiveData` will **NO LONGER** trigger a notification by default, even if the content changed.
  - **Migration**: Use `.update()` for in-place modifications or create a new instance of the collection.

### Dependencies
- Removed `package:collection` dependency.

## 0.11.2
### Doc
- Updated README

## 0.11.1
### Doc
- Updated README

### Tests
- Updated test suite to achieve 100% coverage

## 0.11.0
### Breaking Changes
- `registerSingleton` now requires an instance instead of a factory function.
- Factory functions in Service Locator now has a injection parameter: a function to get dependencies by type. This allows inject dependencies more easily.



## 0.10.2
### Doc
- Updated README. 

## 0.10.1
### Refactor
#### Breaking Changes
  - Updated ViewState to use resolveViewModel() method for ViewModel retrieval.
#### Other
- Updated README documentation to reflect changes in ViewState for ViewModel injection strategy.
- Updated documentation for Service Locator.

## 0.9.1
### Docs
- Added version badge to README.md and API documentation index.html for better visibility of the current package version.

## 0.9.0
### Breaking Changes
- Changed default ViewModel creation strategy in ViewState to use createViewModel() method.
  This allows easier integration with different dependency injection strategies.
### Service Locator
- Added a minimalist built-in service locator `SL` for registering and retrieving ViewModel instances or other dependencies.
- Updated README documentation to include examples of using the built-in service locator.
### Other Improvements
- Updated example views to demonstrate different ViewModel injection strategies using the built-in service locator, Provider, and GetIt.
- Improved code comments and documentation for better clarity on ViewModel management and dependency injection.
- Added tests for ViewModel, RepositoryData, and HotswapLiveData.



## 0.8.4
### Doc
- Small improvement to API documentation layout

## 0.8.3
### Doc
- Updated API documentation to include mvvm_kit logo

## 0.8.2
### Minor
- Updated README to improve documentation and add logo

## 0.8.1
- Fixed typos in ViewModel documentation comments
- Removed deprecated parameters from RepositoryData transform method
- Updated RepositoryData tests to remove deprecated parameters 
- Formatted files for consistency

## 0.8.0

- Initial release of mvvm_kit
- LiveData implementation for reactive state management
- MutableLiveData for mutable observable data
- HotswapLiveData for dynamic data source switching
- ViewModel base class with lifecycle management
- ViewState for connecting views to ViewModels
- Watch and GroupWatch widgets for observing LiveData changes
- DataScope for automatic resource management and disposal
- LiveData transformations: transform, filter, mirror
- RepositoryData pattern for data layer integration
- Comprehensive documentation and examples
