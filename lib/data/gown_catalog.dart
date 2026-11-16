import 'package:flutter/foundation.dart';

import '../models/gown_model.dart';
import 'api_client.dart';

class GownCatalog extends ChangeNotifier {
  GownCatalog._();

  static final GownCatalog instance = GownCatalog._();

	final ApiClient _api = ApiClient.instance;
  List<GownModel> gowns = const [];
  List<GownCategory> categories = const [];
  bool isLoading = false;
  bool hasLoaded = false;
  String? error;
  Future<void>? _pendingLoad;

  Future<void> load({bool refresh = false}) {
	if (_pendingLoad != null) return _pendingLoad!;
	if (hasLoaded && !refresh) return Future<void>.value();

	isLoading = true;
	error = null;
	notifyListeners();
	_pendingLoad = _loadFromBackend();
	return _pendingLoad!;
  }

  Future<void> _loadFromBackend() async {
	try {
	  final results = await Future.wait([
		_api.fetchGowns(),
		_api.fetchCategories(),
	  ]);
	  gowns = results[0] as List<GownModel>;
	  categories = results[1] as List<GownCategory>;
	  hasLoaded = true;
	} catch (exception) {
	  error = exception.toString().replaceFirst('Exception: ', '');
	} finally {
	  isLoading = false;
	  _pendingLoad = null;
	  notifyListeners();
	}
  }

  Future<void> refreshWithLocation({double? userLat, double? userLng}) async {
    try {
      gowns = await _api.fetchGowns(userLat: userLat, userLng: userLng);
      notifyListeners();
    } catch (_) {
      // Keep existing catalog if location-aware refresh fails.
    }
  }
}
