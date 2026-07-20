import 'package:chat_app/features/auth/providers/auth_provider.dart';
import 'package:chat_app/features/chat/screens/home_page.dart';
import 'package:chat_app/features/auth/screens/login_page.dart';
import 'package:chat_app/features/auth/screens/verifyemail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);

    return user.when(
      data: (user) {
        print("AuthGate: ${user?.email}");

        if (user == null) {
          print("Login");
          return const LoginPage();
        }

        if (!user.emailVerified) {
          print("Verify");
          return const VerifyEmailPage();
        }

        print("Home");
        return const HomePage();
      },
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('Something went wrong: $error'))),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
