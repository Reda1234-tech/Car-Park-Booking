import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'maps.dart';
import '../utils/firebase_options.dart';
import '../utils/auth/google_signin.dart';

import 'hoverable.dart';

// Initialize Firebase before running the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, // Use the auto-generated options
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SignupPage(), // Set LoginPage as the default page
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
      navigateToMapScreen(context);
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
                    final success = await GoogleSignin.signInWithGoogle();
                    if (success) {
                      navigateToMapScreen(context);
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
