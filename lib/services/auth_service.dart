import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

/// Custom exception for authentication errors with user-friendly messages.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

/// Abstract contract for authentication services.
/// Allows swapping between real Firebase and mock implementations.
abstract class AuthService {
  Future<UserModel?> login(String email, String password);
  Future<UserModel?> signup(String name, String email, String password);
  Future<void> logout();
  Stream<UserModel?> get authStateChanges;
}

/// Converts Firebase error codes into user-friendly messages.
String _mapFirebaseAuthError(FirebaseAuthException e) {
  switch (e.code) {
    case 'user-not-found':
      return 'No account found with this email. Please sign up first.';
    case 'wrong-password':
      return 'Incorrect password. Please try again.';
    case 'invalid-email':
      return 'The email address is not valid.';
    case 'user-disabled':
      return 'This account has been disabled. Contact support for help.';
    case 'email-already-in-use':
      return 'An account already exists with this email. Try logging in instead.';
    case 'operation-not-allowed':
      return 'Email/password sign-in is not enabled. Contact support.';
    case 'weak-password':
      return 'Password is too weak. Please use at least 6 characters.';
    case 'too-many-requests':
      return 'Too many failed attempts. Please wait a moment and try again.';
    case 'network-request-failed':
      return 'Network error. Please check your internet connection.';
    case 'invalid-credential':
      return 'Invalid email or password. If you don\'t have an account, please Sign Up first.';
    default:
      return e.message ?? 'An unexpected error occurred. Please try again.';
  }
}

/// Real Firebase Authentication implementation.
class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService.instance;

  @override
  Stream<UserModel?> get authStateChanges {
    StreamController<UserModel?>? controller;
    StreamSubscription<User?>? authSub;
    StreamSubscription<UserModel?>? firestoreSub;

    controller = StreamController<UserModel?>.broadcast(
      onListen: () {
        authSub = _auth.userChanges().listen((user) {
          firestoreSub?.cancel();
          if (user == null) {
            controller?.add(null);
            return;
          }

          final isRecentSignUp = user.metadata?.creationTime != null && 
              DateTime.now().difference(user.metadata!.creationTime!) < const Duration(seconds: 10);

          firestoreSub = _firestore.getUserStream(user.uid).listen((userModel) async {
            if (userModel == null) {
              userModel = UserModel(
                uid: user.uid, 
                name: user.displayName != null && user.displayName!.isNotEmpty 
                    ? user.displayName! 
                    : 'Player', 
                email: user.email ?? '',
              );
              if (!isRecentSignUp) {
                await _firestore.saveUser(userModel);
              }
            }
            controller?.add(userModel);
          });
        });
      },
      onCancel: () {
        authSub?.cancel();
        firestoreSub?.cancel();
      },
    );

    return controller.stream;
  }

  @override
  Future<UserModel?> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (cred.user != null) {
        var userModel = await _firestore.getUser(cred.user!.uid);
        
        // Auto-heal missing firestore document
        if (userModel == null) {
          userModel = UserModel(
            uid: cred.user!.uid, 
            name: cred.user!.displayName ?? 'Player', 
            email: cred.user!.email ?? '',
          );
          await _firestore.saveUser(userModel);
        }
        return userModel;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } catch (e) {
      throw const AuthException('Something went wrong. Please try again later.');
    }
  }

  @override
  Future<UserModel?> signup(String name, String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (cred.user != null) {
        // Update the Firebase user display name
        await cred.user!.updateDisplayName(name);

        final user = UserModel(uid: cred.user!.uid, name: name, email: email);
        await _firestore.saveUser(user);
        
        // Reload user to trigger a final userChanges event with the correct display name
        await cred.user!.reload();
        
        return user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } catch (e) {
      throw const AuthException('Something went wrong. Please try again later.');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw const AuthException('Failed to sign out. Please try again.');
    }
  }
}

/// Mock authentication for development and testing without Firebase.
class MockAuthService implements AuthService {
  UserModel? _currentUser;
  final _controller = StreamController<UserModel?>.broadcast();

  @override
  Stream<UserModel?> get authStateChanges async* {
    yield _currentUser;
    yield* _controller.stream;
  }

  @override
  Future<UserModel?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    // Simulate invalid credentials
    if (password.length < 6) {
      throw const AuthException('Incorrect password. Please try again.');
    }

    _currentUser = UserModel(uid: 'mock_uid_1', name: 'Test User', email: email);
    _controller.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
    _controller.add(_currentUser);
  }

  @override
  Future<UserModel?> signup(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    _currentUser = UserModel(uid: 'mock_uid_1', name: name, email: email);
    final mockFirestore = FirestoreService.instance;
    await mockFirestore.saveUser(_currentUser!);
    _controller.add(_currentUser);
    return _currentUser;
  }
}
