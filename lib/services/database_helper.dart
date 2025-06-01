import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/artwork_model.dart';
import '../models/cart_item_model.dart';
import '../models/favorite_model.dart';
import '../models/user_model.dart';

/// Database helper class that manages SQLite database operations for the Khat Husseinii art application.
/// Implements singleton pattern to ensure only one database instance exists.
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  /// Gets the database instance, initializing it if it doesn't exist.
  /// Returns a Future that resolves to the Database instance.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the SQLite database with the specified path and version.
  /// Creates the database file if it doesn't exist and calls _onCreate for table creation.
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'khat_husseinii.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  /// Creates all database tables when the database is first created.
  /// Sets up tables for artworks, cart items, favorites, user profile, and users.
  /// Also inserts initial sample data.
  Future<void> _onCreate(Database db, int version) async {
    // Create artworks table
    await db.execute('''
      CREATE TABLE artworks(
        id TEXT PRIMARY KEY,
        imageUrl TEXT,
        title TEXT,
        description TEXT,
        category TEXT,
        price REAL,
        currency TEXT,
        isFeatured INTEGER
      )
    ''');

    // Create cart items table
    await db.execute('''
      CREATE TABLE cart_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        artworkId TEXT,
        quantity INTEGER,
        addedAt TEXT,
        FOREIGN KEY (artworkId) REFERENCES artworks (id)
      )
    ''');

    // Create favorites table
    await db.execute('''
      CREATE TABLE favorites(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        artworkId TEXT,
        addedAt TEXT,
        FOREIGN KEY (artworkId) REFERENCES artworks (id)
      )
    ''');

    // Create user profile table with updated schema including password
    await db.execute('''
      CREATE TABLE user_profile(
        id INTEGER PRIMARY KEY,
        name TEXT,
        email TEXT UNIQUE,
        phone TEXT,
        address TEXT,
        profileImage TEXT,
        password TEXT
      )
    ''');

    // Create users table for authentication
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT,
        createdAt TEXT
      )
    ''');

    // Insert sample data
    await _insertSampleData(db);
  }

  /// Inserts initial sample data into the database during creation.
  /// Creates a default admin user profile and authentication record.
  Future<void> _insertSampleData(Database db) async {
    // Sample user profile
    await db.insert('user_profile', {
      'id': 1,
      'name': 'Hussein Al-Khatib',
      'email': 'admin@admin.com',
      'phone': '+1234567890',
      'address': '123 Art Street, Creative City',
      'profileImage': 'https://example.com/profile.jpg',
      'password': '1234567', // Add password for the admin user
    });

    // Insert admin user for authentication
    await db.insert('users', {
      'name': 'Admin',
      'email': 'admin@admin.com',
      'password': '1234567',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // Artwork operations

  /// Retrieves all artworks from the database.
  /// Returns a list of Artwork objects containing all artwork records.
  Future<List<Artwork>> getAllArtworks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('artworks');
    return List.generate(maps.length, (i) {
      return Artwork.fromJson(maps[i]);
    });
  }

  /// Retrieves only featured artworks from the database.
  /// Returns a list of Artwork objects where isFeatured is true (1).
  Future<List<Artwork>> getFeaturedArtworks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'artworks',
      where: 'isFeatured = ?',
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) {
      return Artwork.fromJson(maps[i]);
    });
  }

  /// Retrieves artworks filtered by a specific category.
  /// Takes a category string and returns matching Artwork objects.
  Future<List<Artwork>> getArtworksByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'artworks',
      where: 'category = ?',
      whereArgs: [category],
    );
    return List.generate(maps.length, (i) {
      return Artwork.fromJson(maps[i]);
    });
  }

  /// Inserts a new artwork into the database or replaces existing one.
  /// Takes an Artwork object and stores it in the artworks table.
  Future<void> insertArtwork(Artwork artwork) async {
    final db = await database;
    await db.insert(
      'artworks',
      artwork.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Cart operations

  /// Adds an artwork to the shopping cart with specified quantity.
  /// Creates a new cart item record with artwork ID, quantity, and timestamp.
  Future<void> addToCart(String artworkId, int quantity) async {
    final db = await database;
    await db.insert('cart_items', {
      'artworkId': artworkId,
      'quantity': quantity,
      'addedAt': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Retrieves all items in the shopping cart with artwork details.
  /// Joins cart_items and artworks tables to return complete CartItem objects.
  Future<List<CartItem>> getCartItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT ci.*, a.title, a.price, a.imageUrl, a.currency
      FROM cart_items ci
      JOIN artworks a ON ci.artworkId = a.id
    ''');
    return List.generate(maps.length, (i) {
      return CartItem.fromJson(maps[i]);
    });
  }

  /// Removes a specific item from the shopping cart.
  /// Takes the cart item ID and deletes the corresponding record.
  Future<void> removeFromCart(int cartItemId) async {
    final db = await database;
    await db.delete('cart_items', where: 'id = ?', whereArgs: [cartItemId]);
  }

  /// Updates the quantity of a specific cart item.
  /// Takes cart item ID and new quantity, then updates the record.
  Future<void> updateCartItemQuantity(int cartItemId, int quantity) async {
    final db = await database;
    await db.update(
      'cart_items',
      {'quantity': quantity},
      where: 'id = ?',
      whereArgs: [cartItemId],
    );
  }

  /// Removes all items from the shopping cart.
  /// Deletes all records from the cart_items table.
  Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart_items');
  }

  // Favorites operations

  /// Adds an artwork to the user's favorites list.
  /// Creates a new favorite record with artwork ID and timestamp.
  Future<void> addToFavorites(String artworkId) async {
    final db = await database;
    await db.insert('favorites', {
      'artworkId': artworkId,
      'addedAt': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Removes an artwork from the user's favorites list.
  /// Deletes the favorite record matching the specified artwork ID.
  Future<void> removeFromFavorites(String artworkId) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'artworkId = ?',
      whereArgs: [artworkId],
    );
  }

  /// Retrieves all favorite artworks with complete artwork details.
  /// Joins favorites and artworks tables to return Favorite objects.
  Future<List<Favorite>> getFavorites() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT f.*, a.title, a.price, a.imageUrl, a.currency, a.description, a.category
      FROM favorites f
      JOIN artworks a ON f.artworkId = a.id
    ''');
    return List.generate(maps.length, (i) {
      return Favorite.fromJson(maps[i]);
    });
  }

  /// Checks if a specific artwork is in the user's favorites.
  /// Returns true if the artwork is favorited, false otherwise.
  Future<bool> isFavorite(String artworkId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      where: 'artworkId = ?',
      whereArgs: [artworkId],
    );
    return maps.isNotEmpty;
  }

  // User profile operations

  /// Retrieves the user profile for the primary user (ID = 1).
  /// Returns a UserProfile object or null if no profile exists.
  Future<UserProfile?> getUserProfile() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_profile',
      where: 'id = ?',
      whereArgs: [1],
    );
    if (maps.isNotEmpty) {
      return UserProfile.fromJson(maps.first);
    }
    return null;
  }

  /// Updates the user profile information for the primary user.
  /// Takes a UserProfile object and updates the corresponding database record.
  Future<void> updateUserProfile(UserProfile profile) async {
    final db = await database;
    await db.update(
      'user_profile',
      profile.toJson(),
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  // User registration and authentication methods

  /// Registers a new user with name, email, and password.
  /// Checks for existing users, creates both authentication and profile records.
  /// Returns true if registration succeeds, false if user already exists or error occurs.
  Future<bool> registerUser(String name, String email, String password) async {
    final db = await database;
    try {
      // Check if user already exists
      final existing = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (existing.isNotEmpty) {
        return false; // User already exists
      }

      // Insert new user
      final userId = await db.insert('users', {
        'name': name,
        'email': email,
        'password': password,
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Also create a default user profile
      await db.insert('user_profile', {
        'id': userId, // Use the same ID from users table
        'name': name,
        'email': email,
        'phone': '',
        'address': '',
        'profileImage': '',
        'password': password,
      });

      return true;
    } catch (e) {
      print('Error registering user: $e');
      return false;
    }
  }

  /// Authenticates a user with email and password credentials.
  /// Returns true if credentials match an existing user, false otherwise.
  Future<bool> authenticateUser(String email, String password) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> result = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );

      return result.isNotEmpty;
    } catch (e) {
      print('Error authenticating user: $e');
      return false;
    }
  }

  /// Retrieves user profile information by email address.
  /// Returns UserProfile object if found, null if no profile exists for the email.
  Future<UserProfile?> getUserProfileByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_profile',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return UserProfile.fromJson(maps.first);
    }
    return null;
  }
}