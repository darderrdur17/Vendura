import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Authentication
  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Firestore Collections
  static CollectionReference get usersCollection => _firestore.collection('users');
  static CollectionReference get itemsCollection => _firestore.collection('items');
  static CollectionReference get ordersCollection => _firestore.collection('orders');
  static CollectionReference get receiptsCollection => _firestore.collection('receipts');
  static CollectionReference get paymentsCollection => _firestore.collection('payments');

  // Items
  static Future<void> addItem(Map<String, dynamic> itemData) async {
    await itemsCollection.add(itemData);
  }

  static Future<void> updateItem(String itemId, Map<String, dynamic> itemData) async {
    await itemsCollection.doc(itemId).update(itemData);
  }

  static Future<void> deleteItem(String itemId) async {
    await itemsCollection.doc(itemId).delete();
  }

  static Stream<QuerySnapshot> getItemsStream() {
    return itemsCollection
        .orderBy('category')
        .orderBy('name')
        .snapshots();
  }

  // Orders
  static Future<String> addOrder(Map<String, dynamic> orderData) async {
    final docRef = await ordersCollection.add(orderData);
    return docRef.id;
  }

  static Future<void> updateOrder(String orderId, Map<String, dynamic> orderData) async {
    await ordersCollection.doc(orderId).update(orderData);
  }

  static Future<void> deleteOrder(String orderId) async {
    await ordersCollection.doc(orderId).delete();
  }

  static Stream<QuerySnapshot> getOrdersStream() {
    return ordersCollection
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<DocumentSnapshot> getOrder(String orderId) async {
    return await ordersCollection.doc(orderId).get();
  }

  // Receipts
  static Future<String> addReceipt(Map<String, dynamic> receiptData) async {
    final docRef = await receiptsCollection.add(receiptData);
    return docRef.id;
  }

  static Future<void> updateReceipt(String receiptId, Map<String, dynamic> receiptData) async {
    await receiptsCollection.doc(receiptId).update(receiptData);
  }

  static Stream<QuerySnapshot> getReceiptsStream() {
    return receiptsCollection
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<QuerySnapshot> getReceiptsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await receiptsCollection
        .where('createdAt', isGreaterThanOrEqualTo: startDate)
        .where('createdAt', isLessThanOrEqualTo: endDate)
        .orderBy('createdAt', descending: true)
        .get();
  }

  // Payments
  static Future<String> addPayment(Map<String, dynamic> paymentData) async {
    final docRef = await paymentsCollection.add(paymentData);
    return docRef.id;
  }

  static Stream<QuerySnapshot> getPaymentsStream() {
    return paymentsCollection
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Storage
  static Future<String> uploadReceiptImage(String filePath, String fileName) async {
    final ref = _storage.ref().child('receipts/$fileName');
    await ref.putFile(File(filePath));
    return await ref.getDownloadURL();
  }

  static Future<void> deleteReceiptImage(String fileName) async {
    final ref = _storage.ref().child('receipts/$fileName');
    await ref.delete();
  }

  // Batch operations for offline sync
  static Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    final batch = _firestore.batch();
    
    for (final operation in operations) {
      final collection = operation['collection'] as String;
      final data = operation['data'] as Map<String, dynamic>;
      final operationType = operation['type'] as String;
      final documentId = operation['documentId'] as String?;

      switch (operationType) {
        case 'add':
          final docRef = _firestore.collection(collection).doc();
          batch.set(docRef, data);
          break;
        case 'update':
          batch.update(
            _firestore.collection(collection).doc(documentId!),
            data,
          );
          break;
        case 'delete':
          batch.delete(_firestore.collection(collection).doc(documentId!));
          break;
      }
    }

    await batch.commit();
  }

  // Real-time sync status
  static bool get isOnline => _firestore.app.name.isNotEmpty;
}

// Riverpod providers
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseService.authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  return FirebaseService.currentUser;
}); 