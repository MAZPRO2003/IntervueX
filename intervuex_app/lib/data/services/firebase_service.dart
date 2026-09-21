import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static final FirebaseService instance = FirebaseService._internal();
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current authenticated user
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Email and Password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } catch (e) {
      debugPrint("Firebase Sign-In Error: $e");
      rethrow;
    }
  }

  // Register with Email and Password
  Future<UserCredential?> registerWithEmail(String email, String password, {String? displayName}) async {
    try {
      final creds = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (displayName != null && displayName.isNotEmpty) {
        await creds.user?.updateDisplayName(displayName);
      }
      // Initialize user document in Firestore
      if (creds.user != null) {
        await _firestore.collection('users').doc(creds.user!.uid).set({
          'email': email.trim(),
          'displayName': displayName ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      return creds;
    } catch (e) {
      debugPrint("Firebase Registration Error: $e");
      rethrow;
    }
  }

  // Anonymous Sign-In for instant onboarding
  Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      debugPrint("Firebase Anonymous Sign-In Error: $e");
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // --- FIRESTORE USER DATA SYNC ---

  // Save/Toggle Question Mastered/Saved status
  Future<void> syncSavedQuestion(String packId, String questionId, bool isSaved) async {
    final user = currentUser;
    if (user == null) return;
    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('saved_questions')
        .doc('${packId}_$questionId');

    if (isSaved) {
      await docRef.set({
        'packId': packId,
        'questionId': questionId,
        'savedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await docRef.delete();
    }
  }

  // Sync Study Plan Day completion
  Future<void> syncStudyPlanProgress(String packId, int dayNumber, bool isCompleted) async {
    final user = currentUser;
    if (user == null) return;
    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('study_plans')
        .doc(packId);

    await docRef.set({
      'completedDays': isCompleted
          ? FieldValue.arrayUnion([dayNumber])
          : FieldValue.arrayRemove([dayNumber]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Stream of Saved Question IDs for current user
  Stream<List<String>> getSavedQuestionIds(String packId) {
    final user = currentUser;
    if (user == null) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('saved_questions')
        .where('packId', isEqualTo: packId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc['questionId'] as String).toList());
  }
}
