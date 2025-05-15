import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'maps.dart';
import '../untils/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Initialize Firebase before running the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, // Use the auto-generated options
  );
  runApp(const MyApp());
}

void _navigateToMapScreen(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) => MapScreen()), // Navigate to MapScreen
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginPage(), // Set LoginPage as the default page
    );
  }
}

final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId:
      '205984747203-o9a6f76ihpsv9dd6iaj197uh1uso1ref.apps.googleusercontent.com',
);

Future<bool> _signInWithGoogle() async {
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
        await FirebaseFirestore.instance.collection('Users').doc(user.uid).set({
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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _signIn() async {
    String username = _usernameController.text.trim();

    var userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(username)
        .get();

    if (userDoc.exists) {
      // Navigate to MapScreen
      _navigateToMapScreen(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User does not exist! Please sign up.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/sign_in-Photoroom.png', height: 300),
                const SizedBox(height: 20),
                const Text('Welcome back! Login to continue.',
                    textAlign: TextAlign.center),
                const SizedBox(height: 20),
                _buildUsernameField(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _signIn();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Button color
                    foregroundColor: Colors.white, // Text color
                    minimumSize: const Size(150, 40), // Smaller button size
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                    ),
                  ),
                  child: const Text('Login',
                      style: TextStyle(fontSize: 16)), // Smaller font size
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () async {
                    final success = await _signInWithGoogle();
                    if (success) {
                      _navigateToMapScreen(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Failed to sign in with Google.')),
                      );
                    }
                  },
                  icon: Image.asset('assets/images/google_logo.png',
                      height: 20), // or use an icon
                  label: const Text('Sign in with Google'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(200, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                    children: [
                      WidgetSpan(
                        child: HoverableText(
                          text: "Signup",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignupPage()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      decoration: InputDecoration(
        labelText: 'Username',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // Circular border
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Username is required';
        if (value.length < 4 || value.length > 15)
          return 'Username must be 4-15 characters';
        if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*?&]{4,15}$')
            .hasMatch(value)) {
          return 'Must include letters and numbers';
        }
        return null;
      },
    );
  }
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _signUp() async {
    String username = _usernameController.text.trim();
    String email = _nameController.text.trim();

    var userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (userDoc.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User already exists!')),
      );
    } else {
      final newUserRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(); // Auto-generated ID
      await newUserRef.set({
        'user_id': newUserRef.id, // Save the auto-generated ID as user_id
        'name': username,
        'email': email, // Include the email
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User added successfully!')),
      );

      // Navigate to MapScreen
      _navigateToMapScreen(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/sign_in-Photoroom.png', height: 300),
                const SizedBox(height: 20),
                const Text('Sign up to use Easy Parking.',
                    textAlign: TextAlign.center),
                const SizedBox(height: 20),
                _buildTextField(controller: _nameController, label: 'Name'),
                const SizedBox(height: 10),
                _buildUsernameField(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _signUp();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Button color
                    foregroundColor: Colors.white, // Text color
                    minimumSize: const Size(150, 40), // Smaller button size
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                    ),
                  ),
                  child: const Text('Sign Up',
                      style: TextStyle(fontSize: 16)), // Smaller font size
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final success = await _signInWithGoogle();
                    if (success) {
                      _navigateToMapScreen(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Failed to sign in with Google.')),
                      );
                    }
                  },
                  icon: Image.asset('assets/images/google_logo.png',
                      height: 20), // or use an icon
                  label: const Text('Sign in with Google'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(200, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    text: "Already have an account? ",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                    children: [
                      WidgetSpan(
                        child: HoverableText(
                          text: "Login",
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      decoration: InputDecoration(
        labelText: 'Username',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // Circular border
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Username is required';
        if (value.length < 4 || value.length > 15)
          return 'Username must be 4-15 characters';
        if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*?&]{4,15}$')
            .hasMatch(value)) {
          return 'Must include letters and numbers';
        }
        return null;
      },
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller, required String label}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // Circular border
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? '$label is required' : null,
    );
  }
}

// HoverableText Widget
class HoverableText extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const HoverableText({super.key, required this.text, required this.onTap});

  @override
  _HoverableTextState createState() => _HoverableTextState();
}

class _HoverableTextState extends State<HoverableText> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click, // Change cursor to clickable
      onEnter: (_) => setState(() => _isHovered = true), // Hover starts
      onExit: (_) => setState(() => _isHovered = false), // Hover ends
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: _isHovered
                ? Colors.lightBlue[50]
                : Colors.transparent, // Light blue background on hover
            border: Border.all(
              color: _isHovered
                  ? Colors.blue
                  : Colors.transparent, // Blue border on hover
              width: 1, // Border width
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            widget.text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue, // Blue text color
            ),
          ),
        ),
      ),
    );
  }
}
