import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/app_controller.dart';
import '../../core/design/space_theme.dart';

enum AuthMode { login, register, recover }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.controller});
  final AppController controller;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmation = TextEditingController();
  AuthMode mode = AuthMode.login;
  bool busy = false;
  bool obscure = true;
  String? error;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    confirmation.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      switch (mode) {
        case AuthMode.login:
          await widget.controller.login(
            email: email.text,
            password: password.text,
          );
        case AuthMode.register:
          if (password.text != confirmation.text) {
            throw const AuthException('As senhas não coincidem.');
          }
          await widget.controller.register(
            email: email.text,
            password: password.text,
          );
        case AuthMode.recover:
          await widget.controller.recover(email.text);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Instruções de recuperação enviadas.'),
              ),
            );
            setState(() => mode = AuthMode.login);
          }
      }
    } on AuthException catch (exception) {
      setState(() => error = exception.message);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (mode) {
      AuthMode.login => 'Bem-vindo de volta',
      AuthMode.register => 'Crie sua conta',
      AuthMode.recover => 'Recupere seu acesso',
    };
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/room_01.jpg',
            fit: BoxFit.cover,
            color: Colors.black.withValues(alpha: .52),
            colorBlendMode: BlendMode.darken,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, SpaceColors.canvas],
                stops: [.05, .62],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 58, 24, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Column(
                    children: [
                      const SpaceLogo(),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 30),
                      SpaceCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            TextField(
                              controller: email,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              decoration: const InputDecoration(
                                labelText: 'E-mail',
                                prefixIcon: Icon(Icons.mail_outline),
                              ),
                            ),
                            if (mode != AuthMode.recover) ...[
                              const SizedBox(height: 14),
                              TextField(
                                controller: password,
                                obscureText: obscure,
                                autofillHints: mode == AuthMode.login
                                    ? const [AutofillHints.password]
                                    : const [AutofillHints.newPassword],
                                decoration: InputDecoration(
                                  labelText: 'Senha',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    onPressed: () =>
                                        setState(() => obscure = !obscure),
                                    icon: Icon(
                                      obscure
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            if (mode == AuthMode.register) ...[
                              const SizedBox(height: 14),
                              TextField(
                                controller: confirmation,
                                obscureText: obscure,
                                autofillHints: const [
                                  AutofillHints.newPassword,
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Confirmar senha',
                                  prefixIcon: Icon(Icons.lock_reset_outlined),
                                ),
                              ),
                            ],
                            if (error != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    error!,
                                    style: const TextStyle(
                                      color: SpaceColors.error,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 20),
                            FilledButton(
                              onPressed: busy ? null : submit,
                              child: busy
                                  ? const SizedBox.square(
                                      dimension: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      mode == AuthMode.login
                                          ? 'Entrar'
                                          : mode == AuthMode.register
                                          ? 'Criar conta'
                                          : 'Enviar instruções',
                                    ),
                            ),
                            const SizedBox(height: 10),
                            if (mode == AuthMode.login) ...[
                              TextButton(
                                onPressed: () =>
                                    setState(() => mode = AuthMode.recover),
                                child: const Text('Esqueci minha senha'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    setState(() => mode = AuthMode.register),
                                child: const Text('Criar conta'),
                              ),
                            ] else
                              TextButton(
                                onPressed: () => setState(() {
                                  mode = AuthMode.login;
                                  error = null;
                                }),
                                child: const Text('Voltar para entrar'),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Demo local: seus dados ficam neste dispositivo.',
                        style: TextStyle(
                          color: SpaceColors.muted,
                          fontSize: 12,
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
    );
  }
}
