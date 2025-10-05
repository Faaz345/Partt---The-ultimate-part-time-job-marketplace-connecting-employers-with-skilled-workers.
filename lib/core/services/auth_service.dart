import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';
import '../../features/auth/data/models/user_model.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception(AppConstants.errorGeneric);
    }
  }

  // Register with email and password
  Future<UserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception(AppConstants.errorGeneric);
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Sign out first to force account picker to show every time
      await _googleSignIn.signOut();
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final UserCredential result = await _firebaseAuth.signInWithCredential(credential);
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception(AppConstants.errorGeneric);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Sign out from Google Sign In (ignore errors if user didn't sign in with Google)
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        // Google sign out can fail if user didn't sign in with Google, that's fine
        print('Google sign out warning: $e');
      }
      
      // Always sign out from Firebase Auth
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      print('Sign out error: $e');
      // Even if there's an error, try to clear local session
      try {
        await _firebaseAuth.signOut();
      } catch (secondaryError) {
        print('Secondary sign out error: $secondaryError');
      }
      throw Exception('Failed to sign out completely, but local session cleared');
    }
  }

  // Create user profile in Firestore
  Future<void> createUserProfile({
    required UserModel user,
  }) async {
    try {
      await _firestore.collection(AppConstants.usersCollection).doc(user.id).set(user.toFirestore());
    } catch (e) {
      throw Exception('Failed to create user profile');
    }
  }

  // Get user profile from Firestore
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();
      
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .update(user.copyWith(updatedAt: DateTime.now()).toFirestore());
    } catch (e) {
      throw Exception('Failed to update user profile');
    }
  }

  // Check if user exists in Firestore
  Future<bool> userExistsInFirestore(String userId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to send password reset email');
    }
  }

  // Update email
  Future<void> updateEmail(String newEmail) async {
    try {
      await currentUser?.verifyBeforeUpdateEmail(newEmail.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to update email');
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      await currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to update password');
    }
  }

  // Check if email exists with different role
  Future<bool> emailExistsWithDifferentRole(String email, String role) async {
    try {
      final query = await _firestore
          .collection(AppConstants.usersCollection)
          .where('email', isEqualTo: email.trim())
          .where('role', isNotEqualTo: role)
          .limit(1)
          .get();
      
      return query.docs.isNotEmpty;
    } catch (e) {
      print('Error checking email role conflict: $e');
      return false;
    }
  }

  // Check if user exists with specific role
  Future<UserModel?> getUserByEmailAndRole(String email, String role) async {
    try {
      final query = await _firestore
          .collection(AppConstants.usersCollection)
          .where('email', isEqualTo: email.trim())
          .where('role', isEqualTo: role)
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        return UserModel.fromFirestore(query.docs.first);
      }
      return null;
    } catch (e) {
      print('Error getting user by email and role: $e');
      return null;
    }
  }

  // Register user with role validation
  Future<UserCredential?> registerWithRole({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // Check if email already exists with different role
      final hasConflictingRole = await emailExistsWithDifferentRole(email, role);
      if (hasConflictingRole) {
        throw Exception('This email is already registered as a ${role == 'worker' ? 'manager' : 'worker'}. Please use a different email or login with the existing role.');
      }

      // Register with Firebase Auth
      final result = await registerWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return result;
    } catch (e) {
      throw e;
    }
  }

  // Sign in with role validation
  Future<UserCredential?> signInWithRole({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // First check if user exists with the specified role
      final userWithRole = await getUserByEmailAndRole(email, role);
      if (userWithRole == null) {
        // Check if user exists with different role
        final hasConflictingRole = await emailExistsWithDifferentRole(email, role);
        if (hasConflictingRole) {
          throw Exception('This email is registered as a ${role == 'worker' ? 'manager' : 'worker'}. Please select the correct role.');
        }
        throw Exception('No account found with this email as a $role.');
      }

      // Sign in with Firebase Auth
      final result = await signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return result;
    } catch (e) {
      throw e;
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      if (currentUser != null) {
        // Delete user document from Firestore
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(currentUser!.uid)
            .delete();
        
        // Delete Firebase Auth user
        await currentUser!.delete();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to delete account');
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'The account already exists for this email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'Operation not allowed. Please contact support.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please sign in again.';
      default:
        return e.message ?? AppConstants.errorAuth;
    }
  }

  // Verify email
  Future<void> sendEmailVerification() async {
    try {
      await currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to send verification email');
    }
  }

  // Check if email is verified
  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  // Reload current user
  Future<void> reloadUser() async {
    await currentUser?.reload();
  }
}