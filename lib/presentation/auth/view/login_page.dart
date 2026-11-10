import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../l10n/l10n.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/google_sign_in_button.dart';

/// Écran de connexion au compte applicatif (email/mot de passe ou
/// Google) — distinct des comptes Pokémon suivis par l'app (voir
/// `AccountsPage`). Se ferme automatiquement dès que la connexion
/// aboutit.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  /// Bascule entre le formulaire de connexion et celui de création
  /// de compte — même écran, un seul bouton texte pour passer de
  /// l'un à l'autre plutôt que deux pages distinctes.
  bool _isSignUp = false;

  /// Longueur minimale du mot de passe, imposée par Firebase Auth.
  static const int _minPasswordLength = 6;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          Navigator.of(context).pop();
        }
        if (state.status == AuthStatus.error && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        final l10n = context.l10n;
        final isLoading = state.status == AuthStatus.loading;
        return AppScaffold(
          title: _isSignUp ? l10n.loginTitleSignUp : l10n.loginTitleSignIn,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: l10n.loginEmailLabel,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    enabled: !isLoading,
                    validator: _emailValidator,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    decoration:
                        InputDecoration(labelText: l10n.loginPasswordLabel),
                    obscureText: true,
                    enabled: !isLoading,
                    validator: _passwordValidator,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _isSignUp
                                ? l10n.loginSubmitSignUp
                                : l10n.loginSubmitSignIn,
                          ),
                  ),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () => setState(() => _isSignUp = !_isSignUp),
                    child: Text(
                      _isSignUp
                          ? l10n.loginSwitchToSignIn
                          : l10n.loginSwitchToSignUp,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(l10n.loginOr),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GoogleSignInButton(
                    enabled: !isLoading,
                    onPressed: () => context
                        .read<AuthBloc>()
                        .add(const AuthGoogleSignInRequested()),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String? _emailValidator(String? value) {
    final l10n = context.l10n;
    if (value == null || value.trim().isEmpty) return l10n.commonRequired;
    if (!value.contains('@')) return l10n.loginEmailInvalid;
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.length < _minPasswordLength) {
      return context.l10n.loginPasswordTooShort(_minPasswordLength);
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final bloc = context.read<AuthBloc>();
    if (_isSignUp) {
      bloc.add(AuthSignUpRequested(email: email, password: password));
    } else {
      bloc.add(AuthSignInRequested(email: email, password: password));
    }
  }
}