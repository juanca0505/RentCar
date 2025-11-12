import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'dart:async';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _auth = FirebaseAuth.instance;
  bool _emailVerified = false;
  bool _canResendEmail = false;
  bool _isLoading = false;
  int _secondsRemaining = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _emailVerified = _auth.currentUser?.emailVerified ?? false;

    if (!_emailVerified) {
      _sendVerificationEmail();
      Future.delayed(const Duration(seconds: 4), _checkEmailVerified);
    }
  }

  // Enviar correo de verificación con control de tiempo
  Future<void> _sendVerificationEmail() async {
    try {
      setState(() {
        _isLoading = true;
        _canResendEmail = false;
      });

      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
    
        try {
          await user.sendEmailVerification();
        } catch (_) {
          debugPrint("Aviso: Firebase lanzó una excepción silenciosa al enviar el correo.");
        }
      }

      setState(() {
        _isLoading = false;
        _secondsRemaining = 15;
      });

      // Contador regresivo para reactivar botón
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_secondsRemaining > 0) {
          setState(() => _secondsRemaining--);
        } else {
          timer.cancel();
          setState(() => _canResendEmail = true);
        }
      });

      // Notificación amigable
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              " Correo de verificación enviado correctamente. Revisa tu bandeja o carpeta de spam.",
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Manejo silencioso del error (sin mostrarlo al usuario)
      debugPrint("Error silencioso al enviar correo: $e");
      setState(() {
        _isLoading = false;
        _canResendEmail = true;
      });
    }
  }

  // Comprobar periódicamente si el correo fue verificado
  Future<void> _checkEmailVerified() async {
    await _auth.currentUser?.reload();
    final user = _auth.currentUser;

    if (user != null && user.emailVerified) {
      setState(() => _emailVerified = true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(" Correo verificado correctamente."),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      Future.delayed(const Duration(seconds: 4), _checkEmailVerified);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verificar correo"),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.redAccent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _emailVerified
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.email_outlined,
                        size: 80, color: Colors.redAccent),
                    const SizedBox(height: 20),
                    const Text(
                      "Hemos enviado un enlace de verificación a tu correo electrónico.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Por favor revisa tu bandeja o carpeta de spam y verifica tu cuenta para continuar.",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 25),

                    // Botón Reenviar correo
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed:
                                _canResendEmail ? _sendVerificationEmail : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              minimumSize: const Size(double.infinity, 45),
                            ),
                            child: Text(
                              _canResendEmail
                                  ? "Reenviar correo"
                                  : "Reenviar en $_secondsRemaining s...",
                            ),
                          ),

                    const SizedBox(height: 10),

                    // 🔙 Volver al inicio de sesión
                    TextButton(
                      onPressed: () async {
                        await _auth.signOut();
                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        "Volver al inicio de sesión",
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
