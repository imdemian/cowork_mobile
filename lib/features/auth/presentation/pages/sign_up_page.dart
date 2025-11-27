import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cowork_frontend/features/auth/presentation/pages/privacy_policy_page.dart';
import 'package:cowork_frontend/features/auth/presentation/pages/data_protection_page.dart';
import 'package:cowork_frontend/services/google_sign_in_service.dart';
import 'package:cowork_frontend/models/user_model.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _acceptedTerms = false;

  final List<String> _disposableDomains = [
    'temp-mail.org',
    'guerrillamail.com',
    '10minutemail.com',
    'mailinator.com',
    'yopmail.com',
    'sharklasers.com',
    'dispostable.com',
    'maildrop.cc',
    'tempmail.org',
    'throwaway.email',
    'getnada.com',
    'trashmail.com',
    'fakeinbox.com',
    'mintemail.com',
    'temp-mail.io',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _sanitizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingresa tu email.';
    }

    final sanitizedEmail = _sanitizeEmail(value);

    if (sanitizedEmail.length <= 5) {
      return 'El email debe tener más de 5 caracteres.';
    }

    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(sanitizedEmail)) {
      return 'Por favor, ingresa un email válido.';
    }

    final parts = sanitizedEmail.split('@');
    if (parts.length != 2) {
      return 'Formato de email inválido.';
    }

    final domain = parts[1];

    if (_disposableDomains.any(
      (disposable) => domain == disposable || domain.endsWith(disposable),
    )) {
      return 'No se permiten emails desechables. Usa un email válido.';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingresa tu contraseña.';
    }

    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres.';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Debe incluir al menos 1 letra mayúscula.';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Debe incluir al menos 1 letra minúscula.';
    }

    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Debe incluir al menos 1 número.';
    }

    if (!RegExp(r'[@$!%*?&#^()_+=\-\[\]{}|\\:;"<>,.~/`]').hasMatch(value)) {
      return 'Debe incluir al menos 1 símbolo (@!%*?&#, etc.).';
    }

    return null;
  }

  void _signUp() async {
    FocusScope.of(context).unfocus();

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Debes aceptar los términos y condiciones para continuar.',
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final sanitizedEmail = _sanitizeEmail(_emailController.text);

      try {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 16),
                Text('Creando cuenta...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );

        final UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: sanitizedEmail,
              password: _passwordController.text,
            );

        final User? user = userCredential.user;
        if (user != null) {
          await user.sendEmailVerification();

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
                'uid': user.uid,
                'name': '',
                'email': sanitizedEmail,
                'photoURL': '',
                'provider': 'email',
                'createdAt': FieldValue.serverTimestamp(),
                'emailVerified': false,
                'acceptedTerms': true,
                'termsAcceptedAt': FieldValue.serverTimestamp(),
              });

          if (!mounted) return;

          setState(() {
            _isLoading = false;
          });

          _showVerificationDialog();
        }
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        String errorMessage = 'Error al crear la cuenta.';

        if (e.code == 'email-already-in-use') {
          errorMessage =
              'Este email ya está registrado. Por favor, inicia sesión.';
        } else if (e.code == 'weak-password') {
          errorMessage = 'La contraseña es demasiado débil.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Email inválido. Verifica el formato.';
        } else if (e.code == 'operation-not-allowed') {
          errorMessage = 'Registro con email/contraseña no habilitado.';
        } else if (e.message != null) {
          errorMessage = e.message!;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      } catch (e) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, corrige los errores en el formulario.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¡Cuenta creada!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.mark_email_read, size: 64, color: Colors.green),
              const SizedBox(height: 16),
              Text(
                'Hemos enviado un email de verificación a:\n${_emailController.text}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Por favor, verifica tu email antes de iniciar sesión.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signUpWithGoogle() async {
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Debes aceptar los términos y condiciones para continuar.',
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // AHORA DEVUELVE User? DIRECTO
      final User? user = await GoogleSignInService.signInWithGoogle();

      if (!mounted) return;

      if (user != null) {
        // ÉXITO → va directo al Home o Dashboard según rol
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Bienvenido con Google!'),
            backgroundColor: Colors.green,
          ),
        );

        // El AuthWrapper detecta automáticamente si es admin o cliente
        // No necesitas hacer nada más aquí
      } else {
        // Canceló o falló
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inicio de sesión cancelado o fallido'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error con Google: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        automaticallyImplyLeading: canPop,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Procesando...'),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      const Icon(
                        Icons.person_add,
                        size: 80,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        '¡Crea tu cuenta!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Regístrate para comenzar',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 40),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'tu@email.com',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                        onChanged: (value) {
                          final sanitized = _sanitizeEmail(value);
                          if (sanitized != value) {
                            _emailController.value = TextEditingValue(
                              text: sanitized,
                              selection: TextSelection.collapsed(
                                offset: sanitized.length,
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          hintText: 'Mín. 8 caracteres',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscurePassword,
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'La contraseña debe contener:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            _buildPasswordRequirement('• Mínimo 8 caracteres'),
                            _buildPasswordRequirement('• 1 letra mayúscula'),
                            _buildPasswordRequirement('• 1 letra minúscula'),
                            _buildPasswordRequirement('• 1 número'),
                            _buildPasswordRequirement('• 1 símbolo (@!%*?&#)'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _acceptedTerms,
                            onChanged: (value) {
                              setState(() {
                                _acceptedTerms = value ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: GestureDetector(
                                onTap: () => setState(
                                  () => _acceptedTerms = !_acceptedTerms,
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                    ),
                                    children: [
                                      const TextSpan(text: 'Acepto los '),
                                      WidgetSpan(
                                        child: GestureDetector(
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const PrivacyPolicyPage(),
                                            ),
                                          ),
                                          child: Text(
                                            'Términos y Condiciones',
                                            style: TextStyle(
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                              fontWeight: FontWeight.bold,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const TextSpan(text: ' y la '),
                                      WidgetSpan(
                                        child: GestureDetector(
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const DataProtectionPage(),
                                            ),
                                          ),
                                          child: Text(
                                            'Política de Privacidad',
                                            style: TextStyle(
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                              fontWeight: FontWeight.bold,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _signUp,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Crear Cuenta',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _isLoading ? null : _signUpWithGoogle,
                        icon: Image.asset(
                          'assets/google_logo.png',
                          height: 20,
                          width: 20,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.login, size: 20);
                          },
                        ),
                        label: const Text(
                          'Registrarse con Google',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('¿Ya tienes cuenta? '),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Inicia sesión aquí',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
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

  Widget _buildPasswordRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
      ),
    );
  }
}
