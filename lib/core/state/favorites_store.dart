import 'package:flutter/widgets.dart';

class FavoritesStore extends ChangeNotifier {
  FavoritesStore._();

  static final FavoritesStore instance = FavoritesStore._();

  final Set<String> _ids = <String>{};

  bool contains(String id) => _ids.contains(id);
  bool isFavorite(String id) => _ids.contains(id);

  void toggle(String id) {
    if (!_ids.add(id)) {
      _ids.remove(id);
    }
    notifyListeners();
  }

  void remove(String id) {
    if (_ids.remove(id)) notifyListeners();
  }

  void add(String id) {
    if (_ids.add(id)) notifyListeners();
  }
}

class FavoritesScope extends InheritedWidget {
  final FavoritesStore store;
  const FavoritesScope({super.key, required this.store, required super.child});
  static FavoritesStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<FavoritesScope>();
    return scope?.store ?? FavoritesStore.instance;
  }

  @override
  bool updateShouldNotify(covariant FavoritesScope oldWidget) =>
      store != oldWidget.store;
  bool isFavorite(String id) => store.contains(id);
  void toggle(String id) => store.toggle(id);
}
