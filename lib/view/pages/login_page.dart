import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_config.dart';
import '../../controller/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../widgets/app_snackbar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameC = TextEditingController();
  final _passwordC = TextEditingController();
  final AuthController _auth = Get.find<AuthController>();
  bool _obscure = true;
  bool _busy = false;

  Future<void> _login() async {
    setState(() => _busy = true);
    final error = await _auth.login(_usernameC.text, _passwordC.text);
    if (!mounted) return;
    setState(() => _busy = false);

    if (error != null) {
      showAppSnackBar(context, error, color: Colors.red.shade600);
      return;
    }

    Get.offAllNamed(AppRoutes.home);
  }

  @override
  void dispose() {
    _usernameC.dispose();
    _passwordC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.primary,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: scheme.primaryContainer,
                  child: Icon(Icons.storefront, size: 36, color: scheme.primary),
                ),
                const SizedBox(height: 12),
                const Text(
                  AppConfig.appTitle,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text('Silakan login untuk melanjutkan',
                    style: TextStyle(color: Colors.black54)),
                const SizedBox(height: 24),
                TextField(
                  controller: _usernameC,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordC,
                  obscureText: _obscure,
                  onSubmitted: (_) => _busy ? null : _login(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _busy ? null : _login,
                    style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: _busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Login', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
