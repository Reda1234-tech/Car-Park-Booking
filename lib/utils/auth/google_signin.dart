import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoogleSignin {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '205984747203-o9a6f76ihpsv9dd6iaj197uh1uso1ref.apps.googleusercontent.com',
  );

  static Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return false; // User canceled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final String email = user.email!;

        // 🔍 Check if user already exists by email
        final querySnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          // ❗️User not found, create a new document
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(user.uid)
              .set({
            'user_id': user.uid,
            'name': user.displayName ?? 'No Name',
            'email': email,
          });
        }

        return true;
      }
      return false;
    } catch (e) {
      print("Google sign-in error: $e");
      return false;
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Failed to sign in with Google.')),
      // );
    }
  }
}
