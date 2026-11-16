import 'package:flutter/foundation.dart';
import '../../data/api_client.dart';
import '../../models/booking_model.dart';

class BookingStore extends ChangeNotifier {
	BookingStore._();

  static final BookingStore instance = BookingStore._();
	final List<BookingModel> _bookings = [];
  bool isLoading = false;
  String? error;
  String? _loadedToken;
  Future<void>? _pendingLoad;

  List<BookingModel> get bookings => List.unmodifiable(_bookings);

  Future<void> load(String token, {bool refresh = false}) {
	if (_pendingLoad != null) return _pendingLoad!;
	if (_loadedToken == token && !refresh) return Future<void>.value();

	if (_loadedToken != token) _bookings.clear();
	isLoading = true;
	error = null;
	notifyListeners();
	_pendingLoad = _loadFromBackend(token);
	return _pendingLoad!;
  }

  Future<void> _loadFromBackend(String token) async {
	try {
	  final result = await ApiClient.instance.fetchOrders(token);
	  _bookings
		..clear()
		..addAll(result);
	  _loadedToken = token;
	} catch (exception) {
	  error = exception.toString().replaceFirst('Exception: ', '');
	} finally {
	  isLoading = false;
	  _pendingLoad = null;
	  notifyListeners();
	}
  }

  void add(BookingModel booking) {
	_bookings.insert(0, booking);
	notifyListeners();
  }

  void clear() {
	_bookings.clear();
	_loadedToken = null;
	error = null;
	notifyListeners();
  }
}
