import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/product.dart';
import '../models/image.dart';
import '../models/offer.dart';
import '../models/user.dart';
import '../models/category.dart';
import '../models/review.dart';
import '../models/reservation.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class LocalDataService {
  Future<List<Product>> loadProducts() async {
    return loadJson<Product>("products", (json) => Product.fromJson(json));
  }

  Future<List<ImageModel>> loadImages() async {
    return loadJson<ImageModel>("images", (json) => ImageModel.fromJson(json));
  }

  Future<List<Offer>> loadOffers() async {
    return loadJson<Offer>("offers", (json) => Offer.fromJson(json));
  }

  Future<List<User>> loadUsers() async {
    return loadJson<User>("users", (json) => User.fromJson(json));
  }

  Future<List<Category>> loadCategories() async {
    return loadJson<Category>("categories", (json) => Category.fromJson(json));
  }

  Future<List<Review>> loadReviews() async {
    return loadJson<Review>("reviews", (json) => Review.fromJson(json));
  }

  Future<List<Reservation>> loadReservations() async {
    return loadJson<Reservation>("reservations", (json) => Reservation.fromJson(json));
  }
  Future<List<Conversation>> loadConversations() async {
    return loadJson<Conversation>("conversations", (json) => Conversation.fromJson(json));
  }
  Future<List<Message>> loadMessages() async {
    return loadJson<Message>("messages", (json) => Message.fromJson(json));
  }

  Future<List<T>> loadJson<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final String response = await rootBundle.loadString('lib/data/$path.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => fromJson(json)).toList();
  }

  Future<User?> getUserById(int userId) async {
    final users = await loadUsers();
    try {
      return users.firstWhere((u) => u.userId == userId);
    } catch (_) {
      return null;
    }
  }

  Future<User?> getCurrentUser() async {
    final users = await loadUsers();
    return users.firstWhere((u) => u.userId == 1);
  }

  Future<List<Offer>> getOffersByUser(int userId) async {
    final offers = await loadOffers();
    return offers.where((o) => o.userId == userId).toList();
  }

  Future<List<Offer>> getFavoriteOffers(int userId) async {
    final offers = await loadOffers();
    final products = await loadProducts();

    final favoriteProducts = products
        .where((p) => p.isFavorite == true)
        .toList();

    return offers
        .where((o) => favoriteProducts.any((p) => p.productId == o.productId))
        .toList();
  }

  Future<List<Review>> getReviewsForUser(int userId) async {
    final reviews = await loadReviews();
    return reviews.where((r) => r.ownerId == userId).toList();
  }

  Future<Offer?> getOfferById(int offerId) async {
    final offers = await loadOffers();

    try {
      return offers.firstWhere((o) => o.offerId == offerId);
    } catch (_) {
      return null;
    }
  }

  // Conversations for current user
Future<List<Conversation>> getConversationsForCurrentUser() async {
  final current = await getCurrentUser();
  if (current == null) return [];

  final conversations = await loadConversations();
  final items = conversations.where((c) => c.userIds.contains(current.userId)).toList();

  // sort by last message date desc
  items.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
  return items;
}

// Messages for a conversation
Future<List<Message>> getMessagesByConversationId(int conversationId) async {
  final messages = await loadMessages();
  final items = messages.where((m) => m.conversationId == conversationId).toList();

  // sort by date asc
  items.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  return items;
}

// Find an existing conversation for product + 2 users
Future<Conversation?> findConversation(int productId, int user1Id, int user2Id) async {
  final conversations = await loadConversations();

  for (final c in conversations) {
    if (c.productId != productId) continue;
    if (c.userIds.length != 2) continue;
    if (c.userIds.contains(user1Id) && c.userIds.contains(user2Id)) {
      return c;
    }
  }
  return null;
}
}
