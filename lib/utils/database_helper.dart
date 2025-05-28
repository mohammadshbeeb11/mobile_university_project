import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/artwork_model.dart';
import '../models/cart_item_model.dart';
import '../models/favorite_model.dart';
import '../models/user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'khat_husseini.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

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

  Future<void> _insertSampleData(Database db) async {
    // Sample artworks
    final sampleArtworks = [
      {
        'id': '1',
        'imageUrl': 'https://example.com/artwork1.jpg',
        'title': 'يا أبتاه',
        'description':
            'فما يتضع "لبعض" يا أبتاه! أظل "معطلكات" جولة يتهي صقب نتى علقت، تر ةو فوض عمر من إسلامي.',
        'category': 'portraits',
        'price': 100.0,
        'currency': '\$',
        'isFeatured': 1,
      },
      {
        'id': '2',
        'imageUrl': 'https://example.com/artwork2.jpg',
        'title': 'الوليد الأعظم',
        'description': 'عمل فني معقد يجبو عاله مطاليت بتكم ملحيس لوافرار.',
        'category': 'historical',
        'price': 100.0,
        'currency': '\$',
        'isFeatured': 1,
      },
      {
        'id': '3',
        'imageUrl': 'https://example.com/artwork3.jpg',
        'title': 'Islamic Banner',
        'description':
            'Traditional Islamic banner with beautiful calligraphy and ornate designs.',
        'category': 'Banner',
        'price': 150.0,
        'currency': '\$',
        'isFeatured': 0,
      },
      {
        'id': '4',
        'imageUrl': 'https://example.com/artwork4.jpg',
        'title': 'Sacred Flag',
        'description':
            'Historical flag with religious significance and intricate patterns.',
        'category': 'Flag',
        'price': 120.0,
        'currency': '\$',
        'isFeatured': 1,
      },
      {
        'id': '5',
        'imageUrl': 'https://example.com/artwork5.jpg',
        'title': 'Modern Painting',
        'description':
            'Contemporary artwork blending traditional and modern artistic techniques.',
        'category': 'Paintings',
        'price': 200.0,
        'currency': '\$',
        'isFeatured': 0,
      },
      {
        'id': '6',
        'imageUrl': 'https://example.com/artwork6.jpg',
        'title': 'Holy Shrine',
        'description':
            'Artistic representation of a sacred shrine with golden details.',
        'category': 'shrines',
        'price': 300.0,
        'currency': '\$',
        'isFeatured': 1,
      },
    ];

    for (var artwork in sampleArtworks) {
      await db.insert('artworks', artwork);
    }

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
  Future<List<Artwork>> getAllArtworks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('artworks');
    return List.generate(maps.length, (i) {
      return Artwork.fromJson(maps[i]);
    });
  }

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

  Future<void> insertArtwork(Artwork artwork) async {
    final db = await database;
    await db.insert(
      'artworks',
      artwork.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Cart operations
  Future<void> addToCart(String artworkId, int quantity) async {
    final db = await database;
    await db.insert('cart_items', {
      'artworkId': artworkId,
      'quantity': quantity,
      'addedAt': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

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

  Future<void> removeFromCart(int cartItemId) async {
    final db = await database;
    await db.delete('cart_items', where: 'id = ?', whereArgs: [cartItemId]);
  }

  Future<void> updateCartItemQuantity(int cartItemId, int quantity) async {
    final db = await database;
    await db.update(
      'cart_items',
      {'quantity': quantity},
      where: 'id = ?',
      whereArgs: [cartItemId],
    );
  }

  Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart_items');
  }

  // Favorites operations
  Future<void> addToFavorites(String artworkId) async {
    final db = await database;
    await db.insert('favorites', {
      'artworkId': artworkId,
      'addedAt': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeFromFavorites(String artworkId) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'artworkId = ?',
      whereArgs: [artworkId],
    );
  }

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
