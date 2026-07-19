import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/shoppe_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _urlController = TextEditingController();
  bool _isRegistering = false;
  bool _showUrlConfig = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ShoppeProvider>(context, listen: false);
    _urlController.text = provider.tailscaleUrl;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _submit() async {
    HapticFeedback.mediumImpact();
    final provider = Provider.of<ShoppeProvider>(context, listen: false);
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter username and password.')),
      );
      return;
    }

    bool success;
    if (_isRegistering) {
      success = await provider.register(username, password);
    } else {
      success = await provider.login(username, password);
    }

    if (!success && mounted && provider.errorMessage != null) {
      // Show error right next to action per baseline-ui rules
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ShoppeProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6A11CB).withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.bolt, size: 48, color: Colors.white),
                ),
                const SizedBox(height: 24),
                const Text(
                  'ShoppeFake',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Siêu thị mua sắm trực tuyến Shoppe Fake',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 36),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: provider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _isRegistering
                                ? 'CREATE ACCOUNT & GET 5,000 🪙'
                                : 'ENTER THE LOOP',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _isRegistering = !_isRegistering;
                    });
                  },
                  child: Text(
                    _isRegistering
                        ? 'Already have an account? Sign In'
                        : 'New user? Claim your 5,000 🪙 bonus',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Tailscale Configuration drawer/button
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showUrlConfig = !_showUrlConfig;
                    });
                  },
                  icon: Icon(
                    Icons.settings_outlined,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                  tooltip: 'Configure Backend URL (Tailscale)',
                ),
                if (_showUrlConfig)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _urlController,
                            style: const TextStyle(fontSize: 12),
                            decoration: InputDecoration(
                              labelText: 'Backend Base URL (Tailscale / Local)',
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            provider.updateTailscaleUrl(_urlController.text.trim());
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Backend URL updated!'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                          child: const Text('Save',
                              style: TextStyle(fontSize: 12)),
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
}
