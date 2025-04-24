import 'package:flutter/material.dart';
import 'package:movies/src/db_service_firebase.dart';
import 'package:movies/src/home/home_view.dart';
import 'package:movies/src/login/login.controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginView extends StatefulWidget {
  final LoginController controller;

  const LoginView({super.key, required this.controller});

  static const routeName = '/login';

  @override
  LoginViewState createState() => LoginViewState();
}

class LoginViewState extends State<LoginView> {
  double _fontSize = 16.0;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadFontSize();
  }

  Future<void> _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize = prefs.getDouble('font_size') ?? 16.0;
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        await _auth.signInWithEmailAndPassword(
          email: widget.controller.model.mail,
          password: widget.controller.model.password,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Erfolgreich eingeloggt')));
        Navigator.pushNamed(context, HomeView.routeName);
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Fehler beim Login')),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        // Registrierung bei Firebase
        await _auth.createUserWithEmailAndPassword(
          email: widget.controller.model.mail,
          password: widget.controller.model.password,
        );

        // UID holen
        final uid = _auth.currentUser?.uid;
        if (uid != null) {
          final db = DbServiceFirebase(uid);
          await db.initializeUserData();
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrierung erfolgreich!')),
        );
        Navigator.pushNamed(context, HomeView.routeName);
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Registrierung fehlgeschlagen')),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text("Login", style: TextStyle(fontSize: _fontSize)),
                const SizedBox(height: 32),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) => widget.controller.model.mail = value,
                  validator:
                      (value) =>
                          value != null && value.contains('@')
                              ? null
                              : 'Ungültige E-Mail',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Passwort'),
                  obscureText: true,
                  onChanged:
                      (value) => widget.controller.model.password = value,
                  validator:
                      (value) =>
                          value != null && value.length >= 6
                              ? null
                              : 'Mindestens 6 Zeichen',
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator()
                    : Column(
                      children: [
                        ElevatedButton(
                          onPressed: _login,
                          child: const Text('Einloggen'),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _register,
                          child: const Text('Noch kein Konto? Registrieren'),
                        ),
                      ],
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
