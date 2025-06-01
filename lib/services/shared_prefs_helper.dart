import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/cart_item_model.dart';
import '../models/favorite_model.dart';

/// Helper class for managing persistent data storage using SharedPreferences.
/// Handles serialization and deserialization of user profile, cart items, and favorites.
/// Implements singleton pattern to ensure consistent data access across the app.
class SharedPrefsHelper {
  // Keys for SharedPreferences
  static const String userProfileKey = 'user_profile';
  static const String cartItemsKey = 'cart_items';
  static const String favoritesKey = 'favorites';

  // Singleton pattern
  static final SharedPrefsHelper _instance = SharedPrefsHelper._internal();
  factory SharedPrefsHelper() => _instance;
  SharedPrefsHelper._internal();

  // User Profile Methods

  /// Saves user profile data to SharedPreferences.
  /// Converts UserProfile object to JSON and stores it persistently.
  /// Takes a UserProfile object as parameter.
  Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = jsonEncode(profile.toJson());
    await prefs.setString(userProfileKey, profileJson);
  }

  /// Retrieves user profile data from SharedPreferences.
  /// Returns UserProfile object if data exists and is valid, null otherwise.
  /// Handles JSON decoding errors gracefully by returning null.
  Future<UserProfile?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(userProfileKey);

    if (profileJson == null) return null;

    try {
      final Map<String, dynamic> decoded = jsonDecode(profileJson);
      return UserProfile.fromJson(decoded);
    } catch (e) {
      print('Error decoding user profile: $e');
      return null;
    }
  }

  // Cart Items Methods

  /// Saves list of cart items to SharedPreferences.
  /// Converts list of CartItem objects to JSON array and stores persistently.
  /// Takes a list of CartItem objects as parameter.
  Future<void> saveCartItems(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = jsonEncode(items.map((item) => item.toJson()).toList());
    await prefs.setString(cartItemsKey, itemsJson);
  }

  /// Retrieves list of cart items from SharedPreferences.
  /// Returns list of CartItem objects if data exists, empty list otherwise.
  /// Handles JSON decoding errors gracefully by returning empty list.
  Future<List<CartItem>> getCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = prefs.getString(cartItemsKey);

    if (itemsJson == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(itemsJson);
      return decoded.map((item) => CartItem.fromJson(item)).toList();
    } catch (e) {
      print('Error decoding cart items: $e');
      return [];
    }
  }

  /// Removes all cart items from SharedPreferences.
  /// Clears the stored cart data completely.
  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(cartItemsKey);
  }

  // Favorites Methods

  /// Saves list of favorite items to SharedPreferences.
  /// Converts list of Favorite objects to JSON array and stores persistently.
  /// Takes a list of Favorite objects as parameter.
  Future<void> saveFavorites(List<Favorite> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = jsonEncode(
      favorites.map((fav) => fav.toJson()).toList(),
    );
    await prefs.setString(favoritesKey, favoritesJson);
  }

  /// Retrieves list of favorite items from SharedPreferences.
  /// Returns list of Favorite objects if data exists, empty list otherwise.
  /// Handles JSON decoding errors gracefully by returning empty list.
  Future<List<Favorite>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString(favoritesKey);

    if (favoritesJson == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(favoritesJson);
      return decoded.map((fav) => Favorite.fromJson(fav)).toList();
    } catch (e) {
      print('Error decoding favorites: $e');
      return [];
    }
  }

  /// Checks if a specific artwork is marked as favorite.
  /// Takes artwork ID as string parameter.
  /// Returns true if artwork is in favorites list, false otherwise.
  Future<bool> isFavorite(String artworkId) async {
    final favorites = await getFavorites();
    return favorites.any((fav) => fav.artworkId == artworkId);
  }

  // General methods

  /// Clears all stored data from SharedPreferences.
  /// Removes user profile, cart items, favorites, and any other stored data.
  /// Use with caution as this will reset all app data.
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
