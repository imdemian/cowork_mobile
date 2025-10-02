import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Clave global para identificar y validar nuestro formulario.
  final _formKey = GlobalKey<FormState>();

  // Controladores para leer los valores de los campos de texto.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    // Es importante desechar los controladores para liberar memoria.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    // Oculta el teclado para que el usuario pueda ver el SnackBar.
    FocusScope.of(context).unfocus();

    // El método validate() ejecuta el validador de cada TextFormField.
    // Si todos devuelven null (sin errores), retorna true.
    if (_formKey.currentState?.validate() ?? false) {
      // Si el formulario es válido, muestra un SnackBar de éxito.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Login exitoso! Email: ${_emailController.text}'),
          backgroundColor: Colors.green,
        ),
      );
      // Aquí iría la lógica para llamar a tu API o servicio de autenticación.
    } else {
      // Si el formulario no es válido, muestra un SnackBar de error.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, corrige los errores.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: SingleChildScrollView(
        // Evita que los elementos se desborden en pantallas pequeñas
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          // El widget Form es el contenedor para los campos de texto validables.
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa tu email.';
                    }
                    // Expresión regular simple para validar el formato del email.
                    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                      return 'Por favor, ingresa un email válido.';
                    }
                    return null; // Retorna null si la validación es exitosa.
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true, // Oculta el texto de la contraseña.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa tu contraseña.';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres.';
                    }
                    return null; // Retorna null si la validación es exitosa.
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _login, // Llama a la función _login al presionar.
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Iniciar Sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
