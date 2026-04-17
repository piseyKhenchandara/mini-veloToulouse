import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';
import 'register_view_model.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(AuthRepository()),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatelessWidget {
  const _RegisterView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegisterViewModel>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.14),
              AppColors.background,
              const Color(0xFFF7FAF4),
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 24,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Register',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Create your account with email and password.',
                      ),
                      const SizedBox(height: 24),
                      AppTextField(
                        label: 'Email',
                        hintText: 'you@example.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onChanged: context.read<RegisterViewModel>().setEmail,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Password',
                        hintText: 'Enter password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: vm.isPasswordObscured,
                        textInputAction: TextInputAction.next,
                        onChanged: context
                            .read<RegisterViewModel>()
                            .setPassword,
                        suffixIcon: IconButton(
                          onPressed: context
                              .read<RegisterViewModel>()
                              .togglePasswordVisibility,
                          icon: Icon(
                            vm.isPasswordObscured
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Confirm password',
                        hintText: 'Re-enter password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: vm.isConfirmPasswordObscured,
                        textInputAction: TextInputAction.done,
                        onChanged: context
                            .read<RegisterViewModel>()
                            .setConfirmPassword,
                        suffixIcon: IconButton(
                          onPressed: context
                              .read<RegisterViewModel>()
                              .toggleConfirmPasswordVisibility,
                          icon: Icon(
                            vm.isConfirmPasswordObscured
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                        onFieldSubmitted: (_) async {
                          await _register(context);
                        },
                      ),
                      if (vm.errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          vm.errorMessage!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      PrimaryButton(
                        label: vm.isLoading
                            ? 'Creating account...'
                            : 'Register',
                        onPressed: vm.canSubmit
                            ? () async => _register(context)
                            : null,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: vm.isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Back to login'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _register(BuildContext context) async {
    final vm = context.read<RegisterViewModel>();
    final success = await vm.register();

    if (!context.mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully.')),
      );
      Navigator.of(context).pop();
      return;
    }

    final message = vm.errorMessage;
    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
