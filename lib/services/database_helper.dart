import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/artwork_model.dart';
import '../models/cart_item_model.dart';
import '../models/favorite_model.dart';
import '../models/user_model.dart';

class DatabaseHelper {
  // Constants
  static const String _databaseName = 'khat_husseinii.db';
  static const int _databaseVersion = 1;
  static const int _adminUserId = 1;

  // Table names
  static const String _artworksTable = 'artworks';
  static const String _cartItemsTable = 'cart_items';
  static const String _favoritesTable = 'favorites';
  static const String _userProfileTable = 'user_profile';
  static const String _usersTable = 'users';

  // Column names
  static const String _columnId = 'id';
  static const String _columnArtworkId = 'artworkId';
  static const String _columnEmail = 'email';
  static const String _columnPassword = 'password';
  static const String _columnIsFeatured = 'isFeatured';
  static const String _columnCategory = 'category';
  static const String _columnQuantity = 'quantity';

  // Default admin credentials
  static const String _defaultAdminEmail = 'admin@admin.com';
  static const String _defaultAdminPassword = '1234567';
  static const String _defaultAdminName = 'Hussein Al-Khatib';
  static const String _defaultAdminPhone = '+1234567890';
  static const String _defaultAdminAddress = '123 Art Street, Creative City';
  static const String _defaultProfileImage = 'https://example.com/profile.jpg';

  // Singleton implementation
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  /// Gets the database instance, initializing it if it doesn't exist.
  Future<Database> get database async {
    _database ??= await _initializeDatabase();
    return _database!;
  }

  /// Initializes the SQLite database with the specified path and version.
  Future<Database> _initializeDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createTables,
    );
  }

  /// Creates all database tables when the database is first created.
  Future<void> _createTables(Database db, int version) async {
    await _createArtworksTable(db);
    await _createCartItemsTable(db);
    await _createFavoritesTable(db);
    await _createUserProfileTable(db);
    await _createUsersTable(db);
    await _insertDefaultData(db);
  }

  /// Creates the artworks table.
  Future<void> _createArtworksTable(Database db) async {
    await db.execute('''
      CREATE TABLE $_artworksTable(
        $_columnId TEXT PRIMARY KEY,
        imageUrl TEXT,
        title TEXT,
        description TEXT,
        $_columnCategory TEXT,
        price REAL,
        currency TEXT,
        $_columnIsFeatured INTEGER
      )
    ''');
  }

  /// Creates the cart items table.
  Future<void> _createCartItemsTable(Database db) async {
    await db.execute('''
      CREATE TABLE $_cartItemsTable(
        $_columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_columnArtworkId TEXT,
        $_columnQuantity INTEGER,
        addedAt TEXT,
        FOREIGN KEY ($_columnArtworkId) REFERENCES $_artworksTable ($_columnId)
      )
    ''');
  }

  /// Creates the favorites table.
  Future<void> _createFavoritesTable(Database db) async {
    await db.execute('''
      CREATE TABLE $_favoritesTable(
        $_columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_columnArtworkId TEXT,
        addedAt TEXT,
        FOREIGN KEY ($_columnArtworkId) REFERENCES $_artworksTable ($_columnId)
      )
    ''');
  }

  /// Creates the user profile table.
  Future<void> _createUserProfileTable(Database db) async {
    await db.execute('''
      CREATE TABLE $_userProfileTable(
        $_columnId INTEGER PRIMARY KEY,
        name TEXT,
        $_columnEmail TEXT UNIQUE,
        phone TEXT,
        address TEXT,
        profileImage TEXT,
        $_columnPassword TEXT
      )
    ''');
  }

  /// Creates the users table for authentication.
  Future<void> _createUsersTable(Database db) async {
    await db.execute('''
      CREATE TABLE $_usersTable(
        $_columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        $_columnEmail TEXT UNIQUE,
        $_columnPassword TEXT,
        createdAt TEXT
      )
    ''');
  }

  /// Inserts default admin user data.
  Future<void> _insertDefaultData(Database db) async {
    await _insertDefaultUserProfile(db);
    await _insertDefaultAuthUser(db);
  }

  /// Inserts default user profile.
  Future<void> _insertDefaultUserProfile(Database db) async {
    await db.insert(_userProfileTable, {
      _columnId: _adminUserId,
      'name': _defaultAdminName,
      _columnEmail: _defaultAdminEmail,
      'phone': _defaultAdminPhone,
      'address': _defaultAdminAddress,
      'profileImage': _defaultProfileImage,
      _columnPassword: _defaultAdminPassword,
    });
  }

  /// Inserts default authentication user.
  Future<void> _insertDefaultAuthUser(Database db) async {
    await db.insert(_usersTable, {
      'name': 'Admin',
      _columnEmail: _defaultAdminEmail,
      _columnPassword: _defaultAdminPassword,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // Artwork Operations

  /// Retrieves all artworks from the database.
  Future<List<Artwork>> getAllArtworks() async {
    final db = await database;
    final maps = await db.query(_artworksTable);
    return _mapToArtworks(maps);
  }

  /// Retrieves only featured artworks from the database.
  Future<List<Artwork>> getFeaturedArtworks() async {
    final db = await database;
    final maps = await db.query(
      _artworksTable,
      where: '$_columnIsFeatured = ?',
      whereArgs: [1],
    );
    return _mapToArtworks(maps);
  }

  /// Retrieves artworks filtered by a specific category.
  Future<List<Artwork>> getArtworksByCategory(String category) async {
    if (category.isEmpty) throw ArgumentError('Category cannot be empty');

    final db = await database;
    final maps = await db.query(
      _artworksTable,
      where: '$_columnCategory = ?',
      whereArgs: [category],
    );
    return _mapToArtworks(maps);
  }

  /// Inserts a new artwork into the database or replaces existing one.
  Future<void> insertArtwork(Artwork artwork) async {
    final db = await database;
    await db.insert(
      _artworksTable,
      artwork.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Maps database results to Artwork objects.
  List<Artwork> _mapToArtworks(List<Map<String, dynamic>> maps) {
    return maps.map((map) => Artwork.fromJson(map)).toList();
  }

  // Cart Operations

  /// Adds an artwork to the shopping cart with specified quantity.
  Future<void> addToCart(String artworkId, int quantity) async {
    _validateArtworkId(artworkId);
    _validateQuantity(quantity);

    final db = await database;
    await db.insert(_cartItemsTable, {
      _columnArtworkId: artworkId,
      _columnQuantity: quantity,
      'addedAt': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Retrieves all items in the shopping cart with artwork details.
  Future<List<CartItem>> getCartItems() async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT ci.*, a.title, a.price, a.imageUrl, a.currency
      FROM $_cartItemsTable ci
      JOIN $_artworksTable a ON ci.$_columnArtworkId = a.$_columnId
    ''');
    return _mapToCartItems(maps);
  }

  /// Removes a specific item from the shopping cart.
  Future<void> removeFromCart(int cartItemId) async {
    _validateId(cartItemId);

    final db = await database;
    await db.delete(
      _cartItemsTable,
      where: '$_columnId = ?',
      whereArgs: [cartItemId],
    );
  }

  /// Updates the quantity of a specific cart item.
  Future<void> updateCartItemQuantity(int cartItemId, int quantity) async {
    _validateId(cartItemId);
    _validateQuantity(quantity);

    final db = await database;
    await db.update(
      _cartItemsTable,
      {_columnQuantity: quantity},
      where: '$_columnId = ?',
      whereArgs: [cartItemId],
    );
  }

  /// Removes all items from the shopping cart.
  Future<void> clearCart() async {
    final db = await database;
    await db.delete(_cartItemsTable);
  }

  /// Maps database results to CartItem objects.
  List<CartItem> _mapToCartItems(List<Map<String, dynamic>> maps) {
    return maps.map((map) => CartItem.fromJson(map)).toList();
  }

  // Favorites Operations

  /// Adds an artwork to the user's favorites list.
  Future<void> addToFavorites(String artworkId) async {
    _validateArtworkId(artworkId);

    final db = await database;
    await db.insert(_favoritesTable, {
      _columnArtworkId: artworkId,
      'addedAt': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Removes an artwork from the user's favorites list.
  Future<void> removeFromFavorites(String artworkId) async {
    _validateArtworkId(artworkId);

    final db = await database;
    await db.delete(
      _favoritesTable,
      where: '$_columnArtworkId = ?',
      whereArgs: [artworkId],
    );
  }

  /// Retrieves all favorite artworks with complete artwork details.
  Future<List<Favorite>> getFavorites() async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT f.*, a.title, a.price, a.imageUrl, a.currency, a.description, a.$_columnCategory
      FROM $_favoritesTable f
      JOIN $_artworksTable a ON f.$_columnArtworkId = a.$_columnId
    ''');
    return _mapToFavorites(maps);
  }

  /// Checks if a specific artwork is in the user's favorites.
  Future<bool> isFavorite(String artworkId) async {
    _validateArtworkId(artworkId);

    final db = await database;
    final maps = await db.query(
      _favoritesTable,
      where: '$_columnArtworkId = ?',
      whereArgs: [artworkId],
    );
    return maps.isNotEmpty;
  }

  /// Maps database results to Favorite objects.
  List<Favorite> _mapToFavorites(List<Map<String, dynamic>> maps) {
    return maps.map((map) => Favorite.fromJson(map)).toList();
  }

  // User Profile Operations

  /// Retrieves the user profile for the primary user.
  Future<UserProfile?> getUserProfile() async {
    final db = await database;
    final maps = await db.query(
      _userProfileTable,
      where: '$_columnId = ?',
      whereArgs: [_adminUserId],
    );

    return maps.isNotEmpty ? UserProfile.fromJson(maps.first) : null;
  }

  /// Updates the user profile information for the primary user.
  Future<void> updateUserProfile(UserProfile profile) async {
    final db = await database;
    await db.update(
      _userProfileTable,
      profile.toJson(),
      where: '$_columnId = ?',
      whereArgs: [_adminUserId],
    );
  }

  /// Retrieves user profile information by email address.
  Future<UserProfile?> getUserProfileByEmail(String email) async {
    _validateEmail(email);

    final db = await database;
    final maps = await db.query(
      _userProfileTable,
      where: '$_columnEmail = ?',
      whereArgs: [email],
    );

    return maps.isNotEmpty ? UserProfile.fromJson(maps.first) : null;
  }

  // Authentication Operations

  /// Registers a new user with name, email, and password.
  Future<bool> registerUser(String name, String email, String password) async {
    _validateRegistrationData(name, email, password);

    final db = await database;

    try {
      if (await _userExists(email)) {
        return false;
      }

      final userId = await _insertNewUser(db, name, email, password);
      await _createUserProfile(db, userId, name, email, password);

      return true;
    } catch (e) {
      _logError('Error registering user', e);
      return false;
    }
  }

  /// Authenticates a user with email and password credentials.
  Future<bool> authenticateUser(String email, String password) async {
    _validateEmail(email);
    _validatePassword(password);

    try {
      final db = await database;
      final result = await db.query(
        _usersTable,
        where: '$_columnEmail = ? AND $_columnPassword = ?',
        whereArgs: [email, password],
      );

      return result.isNotEmpty;
    } catch (e) {
      _logError('Error authenticating user', e);
      return false;
    }
  }

  /// Checks if a user with the given email already exists.
  Future<bool> _userExists(String email) async {
    final db = await database;
    final existing = await db.query(
      _usersTable,
      where: '$_columnEmail = ?',
      whereArgs: [email],
    );
    return existing.isNotEmpty;
  }

  /// Inserts a new user into the users table.
  Future<int> _insertNewUser(
    Database db,
    String name,
    String email,
    String password,
  ) async {
    return await db.insert(_usersTable, {
      'name': name,
      _columnEmail: email,
      _columnPassword: password,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  /// Creates a user profile for a new user.
  Future<void> _createUserProfile(
    Database db,
    int userId,
    String name,
    String email,
    String password,
  ) async {
    await db.insert(_userProfileTable, {
      _columnId: userId,
      'name': name,
      _columnEmail: email,
      'phone': '',
      'address': '',
      'profileImage': '',
      _columnPassword: password,
    });
  }

  // Validation Methods

  /// Validates artwork ID.
  void _validateArtworkId(String artworkId) {
    if (artworkId.isEmpty) {
      throw ArgumentError('Artwork ID cannot be empty');
    }
  }

  /// Validates quantity.
  void _validateQuantity(int quantity) {
    if (quantity <= 0) {
      throw ArgumentError('Quantity must be greater than 0');
    }
  }

  /// Validates ID.
  void _validateId(int id) {
    if (id <= 0) {
      throw ArgumentError('ID must be greater than 0');
    }
  }

  /// Validates email format.
  void _validateEmail(String email) {
    if (email.isEmpty ||
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      throw ArgumentError('Invalid email format');
    }
  }

  /// Validates password.
  void _validatePassword(String password) {
    if (password.isEmpty) {
      throw ArgumentError('Password cannot be empty');
    }
  }

  /// Validates registration data.
  void _validateRegistrationData(String name, String email, String password) {
    if (name.isEmpty) {
      throw ArgumentError('Name cannot be empty');
    }
    _validateEmail(email);
    _validatePassword(password);
  }

  /// Logs errors with consistent formatting.
  void _logError(String message, dynamic error) {
    print('$message: $error');
  }
}