import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/cart_item_model.dart';
import '../models/favorite_model.dart';

/// Exception thrown when SharedPreferences operations fail
class SharedPrefsException implements Exception {
  final String message;
  final dynamic originalError;

  const SharedPrefsException(this.message, [this.originalError]);

  @override
  String toString() => 'SharedPrefsException: $message';
}

/// Helper class for managing persistent data storage using SharedPreferences.
/// Handles serialization and deserialization of user profile, cart items, and favorites.
/// Implements singleton pattern to ensure consistent data access across the app.
class SharedPrefsHelper {
  // Keys for SharedPreferences
  static const String _userProfileKey = 'user_profile';
  static const String _cartItemsKey = 'cart_items';
  static const String _favoritesKey = 'favorites';

  // Singleton pattern
  static SharedPrefsHelper? _instance;
  static SharedPrefsHelper get instance => _instance ??= SharedPrefsHelper._();
  SharedPrefsHelper._();

  // Cached SharedPreferences instance
  SharedPreferences? _prefs;

  /// Gets SharedPreferences instance with caching
  Future<SharedPreferences> get _sharedPrefs async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  // Generic Methods

  /// Safely encodes object to JSON string
  String _encodeToJson(dynamic object) {
    try {
      return jsonEncode(object);
    } catch (e) {
      throw SharedPrefsException('Failed to encode object to JSON', e);
    }
  }

  /// Safely decodes JSON string to dynamic object
  T _decodeFromJson<T>(String jsonString, T Function(dynamic) fromJson) {
    try {
      final decoded = jsonDecode(jsonString);
      return fromJson(decoded);
    } catch (e) {
      throw SharedPrefsException('Failed to decode JSON', e);
    }
  }

  /// Safely saves data to SharedPreferences
  Future<void> _saveData(String key, String data) async {
    try {
      final prefs = await _sharedPrefs;
      final success = await prefs.setString(key, data);
      if (!success) {
        throw SharedPrefsException('Failed to save data for key: $key');
      }
    } catch (e) {
      if (e is SharedPrefsException) rethrow;
      throw SharedPrefsException('Error saving data for key: $key', e);
    }
  }

  /// Safely retrieves data from SharedPreferences
  Future<String?> _getData(String key) async {
    try {
      final prefs = await _sharedPrefs;
      return prefs.getString(key);
    } catch (e) {
      throw SharedPrefsException('Error retrieving data for key: $key', e);
    }
  }

  /// Safely removes data from SharedPreferences
  Future<void> _removeData(String key) async {
    try {
      final prefs = await _sharedPrefs;
      await prefs.remove(key);
    } catch (e) {
      throw SharedPrefsException('Error removing data for key: $key', e);
    }
  }

  // User Profile Methods

  /// Saves user profile data to SharedPreferences.
  /// Throws [SharedPrefsException] if operation fails.
  Future<void> saveUserProfile(UserProfile profile) async {
    final profileJson = _encodeToJson(profile.toJson());
    await _saveData(_userProfileKey, profileJson);
  }

  /// Retrieves user profile data from SharedPreferences.
  /// Returns [UserProfile] if data exists and is valid, null otherwise.
  /// Throws [SharedPrefsException] if critical error occurs.
  Future<UserProfile?> getUserProfile() async {
    final profileJson = await _getData(_userProfileKey);

    if (profileJson == null) return null;

    return _decodeFromJson(profileJson, (json) => UserProfile.fromJson(json));
  }

  /// Removes user profile from SharedPreferences
  Future<void> clearUserProfile() async {
    await _removeData(_userProfileKey);
  }

  // Cart Items Methods

  /// Saves list of cart items to SharedPreferences.
  /// Throws [SharedPrefsException] if operation fails.
  Future<void> saveCartItems(List<CartItem> items) async {
    final itemsJson = _encodeToJson(
      items.map((item) => item.toJson()).toList(),
    );
    await _saveData(_cartItemsKey, itemsJson);
  }

  /// Retrieves list of cart items from SharedPreferences.
  /// Returns list of [CartItem] objects if data exists, empty list otherwise.
  /// Throws [SharedPrefsException] if critical error occurs.
  Future<List<CartItem>> getCartItems() async {
    final itemsJson = await _getData(_cartItemsKey);

    if (itemsJson == null) return <CartItem>[];

    return _decodeFromJson(
      itemsJson,
      (json) =>
          (json as List<dynamic>)
              .map((item) => CartItem.fromJson(item))
              .toList(),
    );
  }

  /// Adds a single item to cart
  Future<void> addCartItem(CartItem item) async {
    final currentItems = await getCartItems();

    // Check if item already exists and update quantity
    final existingIndex = currentItems.indexWhere(
      (cartItem) => cartItem.id == item.id,
    );

    if (existingIndex >= 0) {
      currentItems[existingIndex] = item;
    } else {
      currentItems.add(item);
    }

    await saveCartItems(currentItems);
  }

  /// Removes a specific item from cart
  Future<void> removeCartItem(String itemId) async {
    final currentItems = await getCartItems();
    currentItems.removeWhere((item) => item.id == itemId);
    await saveCartItems(currentItems);
  }

  /// Removes all cart items from SharedPreferences
  Future<void> clearCart() async {
    await _removeData(_cartItemsKey);
  }

  /// Gets total number of items in cart
  Future<int> getCartItemCount() async {
    final items = await getCartItems();
    return items.fold<int>(0, (sum, item) => sum + (item.quantity ?? 1));
  }

  // Favorites Methods

  /// Saves list of favorite items to SharedPreferences.
  /// Throws [SharedPrefsException] if operation fails.
  Future<void> saveFavorites(List<Favorite> favorites) async {
    final favoritesJson = _encodeToJson(
      favorites.map((fav) => fav.toJson()).toList(),
    );
    await _saveData(_favoritesKey, favoritesJson);
  }

  /// Retrieves list of favorite items from SharedPreferences.
  /// Returns list of [Favorite] objects if data exists, empty list otherwise.
  /// Throws [SharedPrefsException] if critical error occurs.
  Future<List<Favorite>> getFavorites() async {
    final favoritesJson = await _getData(_favoritesKey);

    if (favoritesJson == null) return <Favorite>[];

    return _decodeFromJson(
      favoritesJson,
      (json) =>
          (json as List<dynamic>).map((fav) => Favorite.fromJson(fav)).toList(),
    );
  }

  /// Adds artwork to favorites
  Future<void> addToFavorites(Favorite favorite) async {
    final currentFavorites = await getFavorites();

    // Avoid duplicates
    if (!currentFavorites.any((fav) => fav.artworkId == favorite.artworkId)) {
      currentFavorites.add(favorite);
      await saveFavorites(currentFavorites);
    }
  }

  /// Removes artwork from favorites
  Future<void> removeFromFavorites(String artworkId) async {
    final currentFavorites = await getFavorites();
    currentFavorites.removeWhere((fav) => fav.artworkId == artworkId);
    await saveFavorites(currentFavorites);
  }

  /// Toggles favorite status for artwork
  Future<bool> toggleFavorite(Favorite favorite) async {
    final isFav = await isFavorite(favorite.artworkId);

    if (isFav) {
      await removeFromFavorites(favorite.artworkId);
      return false;
    } else {
      await addToFavorites(favorite);
      return true;
    }
  }

  /// Checks if a specific artwork is marked as favorite.
  /// Returns true if artwork is in favorites list, false otherwise.
  Future<bool> isFavorite(String artworkId) async {
    if (artworkId.isEmpty) return false;

    final favorites = await getFavorites();
    return favorites.any((fav) => fav.artworkId == artworkId);
  }

  // General Methods

  /// Clears all stored data from SharedPreferences.
  /// Use with caution as this will reset all app data.
  Future<void> clearAll() async {
    try {
      final prefs = await _sharedPrefs;
      await prefs.clear();
      _prefs = null; // Reset cached instance
    } catch (e) {
      throw SharedPrefsException('Failed to clear all data', e);
    }
  }

  /// Gets all stored keys (useful for debugging)
  Future<Set<String>> getAllKeys() async {
    try {
      final prefs = await _sharedPrefs;
      return prefs.getKeys();
    } catch (e) {
      throw SharedPrefsException('Failed to get all keys', e);
    }
  }

  /// Checks if app has been initialized with user data
  Future<bool> hasUserData() async {
    final profile = await getUserProfile();
    return profile != null;
  }
}
