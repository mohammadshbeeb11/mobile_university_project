import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/cart_item_model.dart';
import '../models/favorite_model.dart';

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
  Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = jsonEncode(profile.toJson());
    await prefs.setString(userProfileKey, profileJson);
  }

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
  Future<void> saveCartItems(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = jsonEncode(items.map((item) => item.toJson()).toList());
    await prefs.setString(cartItemsKey, itemsJson);
  }

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

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(cartItemsKey);
  }

  // Favorites Methods
  Future<void> saveFavorites(List<Favorite> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = jsonEncode(
      favorites.map((fav) => fav.toJson()).toList(),
    );
    await prefs.setString(favoritesKey, favoritesJson);
  }

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

  Future<bool> isFavorite(String artworkId) async {
    final favorites = await getFavorites();
    return favorites.any((fav) => fav.artworkId == artworkId);
  }

  // General methods
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
